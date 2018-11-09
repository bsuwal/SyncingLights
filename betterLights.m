function betterLights

    clear
    close all

    cleanup_obj = onCleanup(@cleanup);

    % Constants
    Fs = 44100;         % sample rate
    %R =  24;            % number of bits 8,16,24
    C = 1;              % # of channels: mono 1, stereo 2
    T = 0.1;            % length of each batch in seconds
    L = T*Fs;

    RESET_TIME = 3;     % reset max_energy per band, and beat thres every
                        % RESET_TIME mins
    nBands = 5;
    T_buff = 1;
    buffSize = floor(T_buff/T) + 1;     % number of frames whose energy at diff bands
                       % is kept track of - 
    history = zeros(1, buffSize);
    beat_est_thres = 0.08;
    bps = 0;        % initial estimate
    
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
    win = hann(L);       % hanning window
    mic = dsp.AudioRecorder('SampleRate', Fs, ...
                            'NumChannels', C, ...
                            'QueueDuration', 0, ...
                            'SamplesPerFrame', L, ...
                            'OutputNumOverrunSamples', true);

    pause(1);           %let things settle
    disp('Recording ...');
    runTime = tic;
    mic();      % clear buffer and start fresh

    while true 
            [audio, nOverRun] = mic();
            if PRINTED && nOverRun > 5
                fprintf(['Number of samples overrun = %g ', ...
                         '\t \t at t = %.4f mins \n'], ...
                         nOverRun, toc(runTime)/60) 
            end
            X_f = abs(ft(audio .* win));
            X_f = X_f(1:length(f));     % get only the positive frequencies
            [band_eg, maxEnergy] = sendData(obj, f, X_f, maxEnergy, bps);

            % - get bpm estimate by tracking the number of beats in the last
            %   T_buff seconds 
            % - it's a beat if the energy change since last frame is bigger
            %   than the beat threshold
            % - beat threshold is the running average sig. energy difference
            %   reset every RESET_TIME(mins)
            history = [history(2:end-1), sum(audio.^2)/L - history(end), sum(audio.^2)/L];
            history(history < 0) = 0;
            beat_est_thres = (beat_est_thres * (count - 1) + mean(history(1:end-1))) / count;
            bps = sum(history(1:end-1) > beat_est_thres) / (T_buff);
            
            if PLOTTED
                subplot 211
                stem(band_eg)
                grid on
                xlim([0,nBands + 1])
                ylim([0, 250])
                title(sprintf('%g : %g : %.2f , BPM: %.1f ', ...
                                floor(toc(runTime)/3600), ...
                                mod(floor(toc(runTime)/60), 60), ...
                                mod(toc(runTime), 60), ...
                                bps));
                subplot 212
                semilogx(h_fig.CurrentAxes, f, X_f)
                xlabel('Frequency (kHz)')
                ylabel('Normalized X(f)')
                xlim([0 10e3])
                ylim([0 0.01])
                pause(1e-9)
            end

            if abs(mod(toc(runTime)/60,RESET_TIME) - 0) <= 1e-3
               maxEnergy = -9999;
               if PRINTED
                    fprintf('\t\t\t MaxEnergy reset at time %.4f min \n',  toc(runTime)/60)
                    count = 0;
               end
            end
            count = count + 1;
    end

    function cleanup
        fprintf('Done recording. Cleaning up ... \n')
        release(mic);
        release(ft);
        fclose(obj);

        clear all
        close all
        fprintf('All set! \n') 
    end

end