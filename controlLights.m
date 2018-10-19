clear
close all

% Constants
Fs = 44100;         % sample rate
R =  24;            % number of bits 8,16,24
C = 1;              % # of channels: mono 1, stereo 2
T = 2;              % length of each batch in seconds


% debug mode
DEBUG = false;
TEXTSIM = false;

% loop counter
count = 1;
maxEnergy = 0;

tic
recorder = audiorecorder(Fs, R, C); 
record(recorder);
disp('Recording ...')

if DEBUG
    % setup plot
    h_fig = figure(1);
    plot(0.01 * ones(T * Fs, 1))
    xlabel('Frequency (Hz)')
    ylabel('Normalized X(f)')
    xlim([0 6e3])
    ylim([0 1])
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

while true 
   if (toc >= T)
        % Debug code
        if DEBUG
            fprintf('Count = %g \n', count)
            count = count + 1;
        end
        
        % get Data
        audio = getaudiodata(recorder);
        
       % recorder object
        clear recorder; 
        tic
        recorder = audiorecorder(Fs, R, C); 
        record(recorder);
        
        % plot 
        [X_f, f] = getFreq(audio, Fs, DEBUG, h_fig);
        
        sendData(obj, f, X_f, maxEnergy);
   end
end

fclose(obj);