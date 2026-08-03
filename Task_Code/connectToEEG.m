% connect to the EEG amp
function [port, isConnected] = connectToEEG()
    port = [];
    targetPort = 'COM4';
    baudRate = 2000000;
        
    % connect to the port if we can
    try
        port = serialport(targetPort,baudRate);
        isConnected = 1;
    catch ME
        isConnected = 0;
    end
end