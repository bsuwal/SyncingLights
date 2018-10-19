function obj = openSerialPort(comPort, BR)
% function obj = openSerialPort(comPort)
% opens serial port and returns object
% calling example
% obj = openSerialPort('COM3');

obj = serial(comPort, 'BaudRate', BR);
set(obj,'DataBits',8);
set(obj,'Parity','none');
fopen(obj);

return