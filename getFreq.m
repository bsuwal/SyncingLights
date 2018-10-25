function [X_f, f] = getFreq(xs, Fs, isPlotted, h_fig)
    % function [X_w, w] = getFreq(xs, Fs, isPlotted)
    % Gets the fourier transform of a discrete time signal xs
    % and plots the spectrum
    % Inputs:
    %       xs : snap of a signal 
    %       n : sample numbers
    %       Fs : Sampling frequency
    %       plot (optional) : plots if 1
    %       h_fig(optional but needed if plot): 
L = length(xs);
X_f = abs(fft(hamming(L) .* xs));

% Get the spectrum in the range 0 < f < Fs/2 
% max freq is Fs/2 <- sampling theorem
f = Fs/L * (0 : L/2);
X_f = X_f(1 : L/2+1);

% Plot it
if nargin >= 3 && isPlotted 
    plot(h_fig.CurrentAxes, f, abs(X_f));
    xlim([0 6e3])
    ylim([0 100])
    pause(1e-8)
end
return