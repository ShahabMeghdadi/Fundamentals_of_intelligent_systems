function [x_next, Phi_next] = next_phase(x, Phi, theta)  
    % Constants  
    b = 2;  

    % Calculate next values  
    x_next = x + cos(cos(Phi + theta)) + sin(sin(theta)) * sin(sin(Phi));  
    %y_next = y + cos(cos(Phi + theta)) - sin(sin(theta)) * sin(sin(Phi));  
    Phi_next = Phi - (2 * sin(sin(theta)) / b);  
end  