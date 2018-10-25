function [rgb, maxEnergy] = sendData(obj, f, X_f, maxEnergy)
    %   function sendData(obj, f, X_f)
    %   Inputs:
    %       obj : arduino object to write data to
    %       f : frequency
    %       X_f : fourier transform coefficients
    
f_cutoff = [0, ...  % Red light upto
            400, ...   % Green light upto
            1200, ...
            3000, ...
            6000, ...
            15000];      % Blue light upto

%
nBands = length(f_cutoff) - 1;
energy = zeros(1,nBands);
for k = 1 : nBands
    energy(k) = 30 + 20*log10((sum ( X_f(f > f_cutoff(k) & f < f_cutoff(k + 1)) ))^2);
end
maxEnergy = max([maxEnergy, energy]);

% ranking algorithm commented out 
% [~, order] = sort(energy);
rgb = zeros(nBands,1);
for k = 1 : nBands
    % k : frequency band decided by f_cutoff
    % energy(k) = (1 / find(order == k))^2 * energy(k);
    scale = round(energy(k)/maxEnergy * 255);
    rgb(k) = scale;
    fwrite(obj, scale);
end

return