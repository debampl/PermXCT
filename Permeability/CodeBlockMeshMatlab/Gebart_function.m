%
%  Gebart model for transverse and longitudinal flow
%  Mikhail Matveev 12/12/2013
%
function [K_along, K_transverse] = Gebart_function(phi, R, type)
%     Vf = 0.45;
%     R = 15.0e-6/2;
    Vf = 1 - phi; 
    if (type == 0)
        Vf_max_quad = 0.785;
        % Quadratic fibre arrangement
%         K_transverse = 16.0/9/pi/sqrt(2)*(sqrt(Vf_max_quad/Vf)-1)^(2.5)*R^2;
        K_transverse = (16.0/(9*pi*sqrt(2)))*(sqrt(Vf_max_quad/Vf)-1)^(2.5)*R^2;
        K_along = 8.0*R^2 / 57.0 * (1-Vf)^3 / Vf^2;
%     disp(['Quadratic, Vf = ',num2str(Vf)]);
%     disp(['K_trans = ', num2str(K_transverse)]);
%     disp(['K_along = ', num2str(K_along)]);
%     disp(['--------------------------']);
    else
    % Hexagonal
        Vf_max_hex=pi/(2*sqrt(3));
%         K_transverse = 16.0/9/pi/sqrt(6)*(sqrt(Vf_max_hex/Vf)-1)^(2.5)*R^2;
        K_transverse = (16.0/(9*pi*sqrt(6)))*(sqrt(Vf_max_hex/Vf)-1)^(2.5)*R^2;
        K_along = 8.0*R^2 / 53.0 * (1-Vf)^3 / Vf^2;
    end
%     disp(['Hexagonal, Vf = ',num2str(Vf)]);
%     disp(['K_trans = ', num2str(K_transverse)]);
%     disp(['K_along = ', num2str(K_along)]);
%     disp(['--------------------------']);
end