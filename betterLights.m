clear
close all

% Constants
Fs = 44100;         % sample rate
R =  24;            % number of bits 8,16,24
C = 1;              % # of channels: mono 1, stereo 2
T = 0.1;            % length of each batch in seconds
L = T*Fs;

% debug mode
PLOTTED = true;
TEXTSIM = true;
PRINTED = true;

% loop counter
count = 1;
maxEnergy = -9999;

if PLOTTED
    % setup plot
    f = (linspace(0,20e3,100))';
    X_f = 0.005 * ones(size(f));
    h_fig = figure(1);
    semilogx(f, X_f)
    xlabel('Frequency (kHz)')
    ylabel('Normalized X(f)')
    xlim([0 10e3])
    ylim([0 0.01])
else
    h_fig = 0;
end

% output target
if TEXTSIM
    obj = fopen('energies.txt', 'w');
else
    % Arduino serial
    obj = openSerialPort('COM4', 9600);
end

ft = dsp.FFT('Normalize', true);

f = Fs/L * (0: floor((L-1)/2));
win = hann(L);       % window
mic = dsp.AudioRecorder('SampleRate', Fs, ...
                        'NumChannels', C, ...
                        'QueueDuration', 0, ...
                        'SamplesPerFrame', L, ...
                        'OutputNumOverrunSamples', true);

pause(1);           %let things settle
disp('Recording ...');
runTime = tic;
rgb = 0;
[audio, nOverRun] = mic();      % clear buffer and start fresh

while true 
        [audio, nOverRun] = mic();
        if PRINTED && nOverRun > 5
            fprintf(['Number of samples overrun = %g ', ...
                     '\n \t at t = %.4f mins \n'], ...
                     nOverRun, toc(runTime)/60) 
        end
        X_f = abs(ft(audio .* win));
        X_f = X_f(1:length(f));     % get only the positive frequencies
        [rgb, maxEnergy] = sendData(obj, f, X_f, maxEnergy);
        
        if PLOTTED
            subplot 211
            stem(rgb)
            xlim([0,length(rgb) + 1])
            ylim([0, 250])
            title(sprintf('%g : %g : %0.2f', ...
                            floor(toc(runTime)/3600), ...
                            mod(floor(toc(runTime)/60), 60), ...
                            mod(toc(runTime), 60)));
            subplot 212
            semilogx(h_fig.CurrentAxes, f, X_f)
            xlabel('Frequency (kHz)')
            ylabel('Normalized X(f)')
            xlim([0 10e3])
            ylim([0 0.01])
            pause(1e-6)
        end
        
        if abs(mod(toc(runTime)/60,2) - 0) <= 1e-3
           maxEnergy = -9999;
           if PRINTED
                fprintf('\t\t\t MaxEnergy reset at time %.4f min \n',  toc(runTime)/60)
           end
        end
end

release(mic);
release(ft);
fclose(obj);