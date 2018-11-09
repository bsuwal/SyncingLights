function [band_eg, maxEnergy] = sendData(obj, f, X_f, maxEnergy, bpm)
    %   function sendData(obj, f, X_f)
    %   Inputs:
    %       obj : arduino object to write data to
    %       f : frequency
    %       X_f : fourier transform coefficients
    
f_cutoff = [0, ... 
            400, ...   
            1200, ...
            3000, ...
            6000, ...
            15000];      

%
nBands = length(f_cutoff) - 1;
energy = zeros(nBands, 1);

for k = 1 : nBands
    energy(k) = 30 + 20*log10((sum ( X_f(f > f_cutoff(k) & f < f_cutoff(k + 1)) ))^2);
end
maxEnergy = max([maxEnergy; energy]);

% send bpm, then send band energies in order - a byte per data
fwrite(obj, uint8(bpm));

% ranking algorithm commented out 
% [~, order] = sort(energy);
band_eg = zeros(nBands,1);
for k = 1 : nBands
    % k : frequency band decided by f_cutoff
    % energy(k) = (1 / find(order == k))^2 * energy(k);
    scale = round(energy(k)/maxEnergy * 255);
    band_eg(k) = scale;
    fwrite(obj, uint8(scale));
end

return