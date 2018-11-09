fprintf('Done recording. Cleaning up ... \n')
release(mic);
release(ft);
fclose(obj);

clear all
close all
fprintf('All set! \n')