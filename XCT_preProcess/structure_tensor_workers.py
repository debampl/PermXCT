"""Module containing workers for structure tensor analysis.

Author: Niels Jeppesen (niejep@dtu.dk)
"""
import logging
import time

import numpy as np
from structure_tensor import st3d

try:
    import cupy as cp
    from structure_tensor.cp import st3dcp
except Exception as ex:
    cp = None
    logging.warning("Could not load CuPy for structure tensor analysis: %s", str(ex))

# A global dictionary storing the variables passed from the initializer.
var_dict = {}


def init_worker(kwargs):
    """Initialization method for worker."""

    data = kwargs['data']

    if isinstance(data, str):
        # We expect it to the a path to a file.
        var_dict['data'] = np.memmap(data, dtype=kwargs['dtype'], shape=kwargs['shape'], mode='r')

    mask = kwargs.get('mask', None)

    if isinstance(mask, str):
        # We expect it to the a path to a file.
        var_dict['mask'] = np.memmap(mask, dtype=np.bool, shape=kwargs['shape'], mode='r')

    var_dict['sigma'] = kwargs['sigma']
    var_dict['rho'] = kwargs['rho']
    var_dict['crop_size'] = kwargs.get('crop_size', 256)
    var_dict['ignore_boundary'] = kwargs.get('ignore_boundary', False)
    var_dict['threshold'] = kwargs.get('threshold', None)
    var_dict['class_vectors'] = kwargs.get('class_vectors', None)
    var_dict['device'] = kwargs.get('device', None)
    var_dict['orientation_correction'] = kwargs.get('orientation_correction', None)
    var_dict['S_calc_dtype'] = kwargs.get('S_calc_dtype', np.float32)
    var_dict['eig_calc_dtype'] = kwargs.get('eig_calc_dtype', np.float64)
    var_dict['bins_per_degree'] = kwargs.get('bins_per_degree', 1)
    var_dict['return_aggregate'] = kwargs.get('return_aggregate', False)

    S = kwargs.get('S', None)

    if isinstance(S, str):
        # We expect it to the a path to a file.
        var_dict['S'] = np.memmap(S, dtype=kwargs['S_dtype'], shape=(6, ) + kwargs['shape'], mode='r+')

    val = kwargs.get('val', None)

    if isinstance(val, str):
        # We expect it to the a path to a file.
        var_dict['val'] = np.memmap(val, dtype=kwargs['val_dtype'], shape=(3, ) + kwargs['shape'], mode='r+')

    vec = kwargs.get('vec', None)

    if isinstance(vec, str):
        # We expect it to the a path to a file.
        var_dict['vec'] = np.memmap(vec, dtype=kwargs['vec_dtype'], shape=(3, ) + kwargs['shape'], mode='r+')

    for n in ['vec_class', 'eta_os', 'theta', 'in_xy_angle', 'out_xy_angle']:
        path = kwargs.get(n, None)
        if isinstance(path, str):
            # We expect it to the a path to a file.
            var_dict[n] = np.memmap(path, dtype=kwargs[f'{n}_dtype'], shape=kwargs['shape'], mode='r+')


def structure_tensor_analysis_v1(i):
    """Worker function for structure tensor analysis."""

    # Start timer.
    start = time.time()

    # Read out arguments.
    data = var_dict['data']
    mask = var_dict.get('mask', None)
    sigma = var_dict['sigma']
    rho = var_dict['rho']
    crop_size = var_dict['crop_size']
    ignore_boundary = var_dict.get('ignore_boundary', False)
    threshold = var_dict['threshold']
    class_vectors = var_dict['class_vectors']
    orientation_correction = var_dict['orientation_correction']
    S_calc_dtype = var_dict['S_calc_dtype']
    eig_calc_dtype = var_dict['eig_calc_dtype']
    bins_per_degree = var_dict['bins_per_degree']
    return_aggregate = var_dict['return_aggregate']
    device = var_dict['device']
    S_map = var_dict.get('S', None)
    val_map = var_dict.get('val', None)
    vec_map = var_dict.get('vec', None)
    vec_class_map = var_dict.get('vec_class', None)
    theta_map = var_dict.get('theta', None)
    eta_os_map = var_dict.get('eta_os', None)
    in_xy_angle_map = var_dict.get('in_xy_angle', None)
    out_xy_angle_map = var_dict.get('out_xy_angle', None)

    if isinstance(device, list) or isinstance(device, tuple):
        # If more devices are provided select one.
        device = device[i % len(device)]
        # Overwrite initial device value to prevent process changing device on next iteration.
        var_dict['device'] = device

    if cp is not None and isinstance(device, str) and device.startswith('cuda'):

        split = device.split(':')
        if len(split) > 1:
            # Overwrite initial device value to prevent process changing device on next iteration.
            var_dict['device'] = split[0]

            # CUDA device ID specified. Use that device.
            device_id = int(split[1])
            cp.cuda.Device(device_id).use()

        # Use CuPy.
        st = st3dcp
        lib = cp
    else:
        # Use NumPy.
        st = st3d
        lib = np

    # Check if mask has values.
    if mask is not None:
        mask, pos, pad = get_crop(i, mask, 0, crop_size=crop_size)
        if not lib.any(mask):
            # No data is this crop, so just return.
            stop = time.time()
            return stop - start, None

    # Ensure class vectors are array.
    class_vectors = lib.asarray(class_vectors)

    # Transpose orientation rotation matrix.
    if orientation_correction is not None:
        orientation_correction = lib.asarray(orientation_correction.transpose())

    # Get crop.
    crop, pos, pad = get_crop(i, data, max(rho, sigma), crop_size=crop_size)

    # Copy crop and convert data type. Currently we use float32 for performance.
    crop = lib.array(crop, dtype=S_calc_dtype)
    crop_no_padding = remove_padding(crop, pos, pad)

    # Check if we should mask out values affected by padding.
    if ignore_boundary:
        # Create mask.
        ignore_boundary_mask = lib.zeros(crop_no_padding.shape, dtype=lib.bool)
        remove_boundary(ignore_boundary_mask, pad, max(sigma, rho))[:] = True
        if mask is None:
            mask = ignore_boundary_mask
        else:
            mask &= ignore_boundary_mask
        del ignore_boundary_mask

    threshold_mask = None
    if threshold is not None:
        # Get mask with data of interest.
        threshold_mask = crop_no_padding > threshold
        if mask is None:
            mask = threshold_mask
        else:
            mask &= threshold_mask

    data_count = 0
    if mask is not None:
        data_count = lib.count_nonzero(mask)

        if data_count == mask.size:
            # Remove mask if we're saving output map.
            mask = None

    if data_count == 0:
        # No data is this crop, so just return.
        stop = time.time()
        return stop - start, None

    # Calculate S. This is the slowest bit.
    S = st.structure_tensor_3d(crop, sigma, rho)

    # Remove padding from S.
    S = remove_padding(S, pos, pad)

    if S_map is not None:
        # Insert values in array if relevant.
        insert_crop(S_map, scale_and_cast(S, S_map.dtype), pos, pad, is_padded=False)

    # Convert data type if necessary.
    if S.dtype != eig_calc_dtype:
        S = S.astype(eig_calc_dtype)

    # Calculate eigen vectors. This is the second slowest bit.
    val, vec = st.eig_special_3d(S, full=False)

    del S

    if val_map is not None:
        # Flip so largest value is first.
        val = lib.flip(val, axis=0)

        # Insert values in array if relevant.
        insert_crop(val_map, scale_and_cast(val, val_map.dtype), pos, pad, is_padded=False)

    del val

    if vec_map is not None:
        # Insert values in array if relevant.
        insert_crop(vec_map, scale_and_cast(vec, vec_map.dtype), pos, pad, is_padded=False)

    if mask is not None:
        # Get values of interest.
        vec = vec[:, mask]

    if orientation_correction is not None:
        # Correct orientation of vectors.
        lib.dot(orientation_correction, vec, out=vec)

    vec_class, eta_os, theta, out_xy_angle, in_xy_angle = calculate_angles(vec, class_vectors)

    # Save results to files if they're provided.
    for v, m in zip([vec_class, eta_os, theta, in_xy_angle, out_xy_angle], [vec_class_map, eta_os_map, theta_map, in_xy_angle_map, out_xy_angle_map]):
        if m is not None:
            # Insert values in array if relevant.
            insert_crop(m, scale_and_cast(v, m.dtype), pos, pad, is_padded=False, mask=mask)

    if not return_aggregate:
        # If we're not returning aggregate, return now.
        stop = time.time()
        return stop - start

    results = []

    # Create class mask.
    class_mask = lib.ones(vec_class.shape, dtype=lib.bool)

    # For all classes combined (-1) and each class...
    for i in range(-1, len(class_vectors)):

        if i >= 0:
            lib.equal(vec_class, i, out=class_mask)

        # Number of samples.
        count = lib.count_nonzero(class_mask)

        if count == 0:
            if cp is not None:
                count = cp.asnumpy(count)
            results.append((count, 0, 0, 0, np.zeros(90 * bins_per_degree), 0, 0, np.zeros(180 * bins_per_degree), 0, 0, np.zeros(180 * bins_per_degree)))
            continue

        # Calculate eta_o for class.
        eta_o = lib.mean(eta_os[class_mask])

        # Angle from x.
        theta_class = theta[class_mask]
        theta_mean = lib.mean(theta_class)
        theta_std = lib.std(theta_class)
        theta_hist = lib.histogram(theta_class, bins=lib.linspace(0, 90, 90 * bins_per_degree + 1))[0]

        # Angle xz-plane.
        out_xy_angle_class = out_xy_angle[class_mask]
        out_xy_angle_mean = lib.mean(out_xy_angle_class)
        out_xy_angle_std = lib.std(out_xy_angle_class)
        out_xy_angle_hist = lib.histogram(out_xy_angle_class, bins=lib.linspace(-90, 90, 180 * bins_per_degree + 1))[0]

        # Angle xy-plane.
        in_xy_angle_class = in_xy_angle[class_mask]
        in_xy_angle_mean = lib.mean(in_xy_angle_class)
        in_xy_angle_std = lib.std(in_xy_angle_class)
        in_xy_angle_hist = lib.histogram(in_xy_angle_class, bins=lib.linspace(-90, 90, 180 * bins_per_degree + 1))[0]

        if cp is not None:
            count = cp.asnumpy(count)
            eta_o = cp.asnumpy(eta_o)
            theta_mean = cp.asnumpy(theta_mean)
            theta_std = cp.asnumpy(theta_std)
            theta_hist = cp.asnumpy(theta_hist)
            out_xy_angle_mean = cp.asnumpy(out_xy_angle_mean)
            out_xy_angle_std = cp.asnumpy(out_xy_angle_std)
            in_xy_angle_hist = cp.asnumpy(in_xy_angle_hist)
            in_xy_angle_mean = cp.asnumpy(in_xy_angle_mean)
            in_xy_angle_std = cp.asnumpy(in_xy_angle_std)
            out_xy_angle_hist = cp.asnumpy(out_xy_angle_hist)

        # Add to results list.
        results.append(
            (count, eta_o, theta_mean, theta_std, theta_hist, in_xy_angle_mean, in_xy_angle_std, in_xy_angle_hist, out_xy_angle_mean, out_xy_angle_std, out_xy_angle_hist))

    stop = time.time()

    return stop - start, results


def calculate_angles(vec, class_vectors):

    if cp is not None and isinstance(vec, cp.ndarray):
        lib = cp
    else:
        lib = np

    shape = class_vectors.shape[:1] + vec.shape[1:]

    # Calculate dot product between each class vector and ST vectors.
    vec_dots = lib.einsum('ij,oi->oj', vec.reshape(3, -1), class_vectors).reshape(shape)
    lib.abs(vec_dots, out=vec_dots)

    # Determine classes.
    vec_class = lib.empty(vec_dots.shape[1:], dtype=lib.uint8)
    vec_class = lib.argmax(vec_dots, axis=0, out=vec_class)

    # Get angle from x-axis.
    cos_theta = vec_dots[0]

    # Calculate eta_o.
    cos_theta_4 = lib.multiply(cos_theta, cos_theta)
    eta_os = lib.multiply(cos_theta_4, cos_theta_4, out=cos_theta_4)

    # Calculate theta.
    theta = lib.arccos(cos_theta, out=cos_theta)
    theta = lib.degrees(theta, out=theta)

    # Calculate rotation of projection onto xy-plane.
    in_plane_xy = lib.arctan(vec[1] / vec[2])
    lib.degrees(in_plane_xy, out=in_plane_xy)

    # Flip vectors to all be positive on x-axis.
    out_of_plane_xy = vec[0] * lib.sign(vec[2])
    # Calculate out of xy-plane angle.
    lib.arcsin(out_of_plane_xy, out=out_of_plane_xy)
    lib.degrees(out_of_plane_xy, out=out_of_plane_xy)

    return vec_class, eta_os, theta, out_of_plane_xy, in_plane_xy


def get_crop(i, data, sigma, crop_size=512, truncate=4, copy=False):
    kernel_radius = int(sigma * truncate + 0.5)
    count = 0

    for x0 in range(0, data.shape[0], crop_size):
        x1 = x0 + crop_size
        for y0 in range(0, data.shape[1], crop_size):
            y1 = y0 + crop_size
            for z0 in range(0, data.shape[2], crop_size):
                z1 = z0 + crop_size

                if count == i:
                    crop = data[max(0, x0 - kernel_radius):x1 + kernel_radius,
                                max(0, y0 - kernel_radius):y1 + kernel_radius,
                                max(0, z0 - kernel_radius):z1 + kernel_radius]

                    cx0 = kernel_radius + min(0, x0 - kernel_radius)
                    cy0 = kernel_radius + min(0, y0 - kernel_radius)
                    cz0 = kernel_radius + min(0, z0 - kernel_radius)
                    cx1 = max(0, min(kernel_radius, data.shape[0] - x1))
                    cy1 = max(0, min(kernel_radius, data.shape[1] - y1))
                    cz1 = max(0, min(kernel_radius, data.shape[2] - z1))

                    if copy:
                        crop = np.array(crop)

                    return crop, np.array(((x0, x1), (y0, y1), (z0, z1))), np.array(((cx0, cx1), (cy0, cy1), (cz0, cz1)))

                count += 1

    raise IndexError(f"Index {i} is out of bounds for {count} crops.")


def get_crop_generator(data, sigma, crop_size=512, truncate=4, copy=False):
    kernel_radius = int(sigma * truncate + 0.5)

    for x0 in range(0, data.shape[0], crop_size):
        x1 = x0 + crop_size
        for y0 in range(0, data.shape[1], crop_size):
            y1 = y0 + crop_size
            for z0 in range(0, data.shape[2], crop_size):
                z1 = z0 + crop_size

                crop = data[max(0, x0 - kernel_radius):x1 + kernel_radius,
                            max(0, y0 - kernel_radius):y1 + kernel_radius,
                            max(0, z0 - kernel_radius):z1 + kernel_radius]

                cx0 = kernel_radius + min(0, x0 - kernel_radius)
                cy0 = kernel_radius + min(0, y0 - kernel_radius)
                cz0 = kernel_radius + min(0, z0 - kernel_radius)
                cx1 = max(0, min(kernel_radius, data.shape[0] - x1))
                cy1 = max(0, min(kernel_radius, data.shape[1] - y1))
                cz1 = max(0, min(kernel_radius, data.shape[2] - z1))

                if copy:
                    crop = np.array(crop)

                yield crop, np.array(((x0, x1), (y0, y1), (z0, z1))), np.array(((cx0, cx1), (cy0, cy1), (cz0, cz1)))


def get_crops(data, sigma, crop_size=512, truncate=4, copy=False):
    crops = []
    crop_positions = []
    crop_paddings = []

    for crop, pos, pad in get_crop_generator(data, sigma, crop_size=crop_size, truncate=truncate, copy=copy):
        crops.append(crop)
        crop_positions.append(pos)
        crop_paddings.append(pad)

    return crops, np.array(crop_positions), np.array(crop_paddings)


def remove_padding(crop, pos, pad):
    crop = crop[..., pad[0, 0]:crop.shape[-3] - pad[0, 1], pad[1, 0]:crop.shape[-2] - pad[1, 1], pad[2, 0]:crop.shape[-1] - pad[2, 1]]
    return crop


def remove_boundary(crop, pad, sigma, truncate=4):
    kernel_radius = int(sigma * truncate + 0.5)
    boundary = kernel_radius - pad
    crop = crop[boundary[0, 0]:crop.shape[0] - boundary[0, 1], boundary[1, 0]:crop.shape[1] - boundary[1, 1], boundary[2, 0]:crop.shape[2] - boundary[2, 1]]
    return crop


def insert_crop(a, crop, pos, pad, is_padded=True, mask=None):
    if is_padded:
        crop = remove_padding(crop, pos, pad)

    view = a[..., pos[0, 0]:pos[0, 1], pos[1, 0]:pos[1, 1], pos[2, 0]:pos[2, 1]]
    if mask is None:
        view[:] = crop
    else:
        if cp is not None and isinstance(mask, cp.ndarray):
            mask = cp.asnumpy(mask)
        view[..., mask] = crop


def scale_and_cast(a, dtype, to_numpy=True, rescale=False):

    # Copy data to new var.
    a = a.copy()

    if np.issubdtype(a.dtype, np.floating) and np.issubdtype(dtype, np.integer):
        if rescale:
            # Rescale to fill integer space.
            to_info = np.iinfo(dtype)
            scale = to_info.max / a.abs().max()
            a *= scale

        # Round in-place.
        a.round(out=a)

    # Cast type.
    a = a.astype(dtype)

    if cp is not None and to_numpy:
        # Convert to NumPy.
        a = cp.asnumpy(a)

    return a
