function [latDD lonDD UTM]=ReadNAVdrifter;

% ReadNAV reads the serial GPS stream from a ship, parses the navigation data 
% and plots the ships track. nav is the serial port object returned from ConnectNAVport
% Latitude, longitude and time vectors are returned to the shell script and available 
% from the command upon program exit.
% D. Jensen June 2008

s_port=['COM3'];
pause(0.1)

% Script to create a serial port object and connect to NAV input stream

% Create a serial port object.
nav = instrfind('Type', 'serial', 'Port', 'COM3', 'Tag', '');

% Create the serial port object if it does not exist
% otherwise use the object that was found.
if isempty(nav)
    nav = serial(s_port);
else
    fclose(nav);
    nav = nav(1);
end

set(nav, 'BaudRate', 4800, 'DataBits', 8, 'Parity', 'none', 'StopBits', 1, 'Terminator', 'CR/LF');

set(nav, 'ReadAsyncMode', 'Continuous') ; % set the asynchronous mode to continuous by default it is continuous
set(nav, 'Timeout', 2) ;                % Specify timeout for read operation

% Connect to instrument object, nav.
fopen(nav);

clear loc s_port

LAT=[]; LON=[]; 

% We only want the strings with $GPGGA…  
while(1)

    data='';
    while isempty(strmatch('$GPGGA',data))
        data = fgetl(nav);
        if data==-1;
            return
        end
        if strmatch('$GPGGA',data)
            break
%             t=t+1;
%             if mod(t,30) > 0
%                 data='';
%             end
        end
    end

    %$GPGGA,192853,3240.9646,N,11732.3389,W,1,8,2.0,18,M,,M,,*58
    %$GPGGA  1 - UTC of position data (hhmmss)
    %        2 - latdeg decimal minutes
    %        3 - lat hem
    %        4 - longdeg decimal minutes
    %        5 - lon hem
    %        6 - GPS quality indicator (0=invalid; 1=GPS fix; 2=Diff. GPS fix)
    %        7 - Number of satellites in use
    %        8 - Horizontal dilution of position
    %        9 - Antenna altitude above/below mean sea level
    %       10 - Meters (Antenna height unit)
    %       11 - Geoidal separation (Diff. between WGS-84 earth ellipsoid and mean sea level. -=geoid is below WGS-84 ellipsoid)
    %       12 - Meters (Units of geoidal separation)
    %       13 - Age in seconds since last update from diff. reference station
    %       14 - Diff. reference station ID#
    %       15 - * checksum

    % Parse the string to obtain coordinates
    [str,data] = strtok(data,',');
    [UTM,data] = strtok(data,',');
    [lat,data] = strtok(data,',');
    [latHem,data] = strtok(data,',');
    [lon,data] = strtok(data,',');
    [lonHem,data] = strtok(data,',');
    % don't need anything else right now

    % put positions in decimal degrees
    latDM = [lat(1:2) ' ' lat(3:length(lat))];
    lonDM = [lon(1:3) ' ' lon(4:length(lon))];
    latDD = str2double(lat(1:2)) + str2double(lat(3:length(lat)))/60;
    lonDD = str2double(lon(1:3)) + str2double(lon(4:length(lon)))/60;
    
    lonDD=-lonDD;
    
    UTM = [UTM(1:2) ':' UTM(3:4) ':' UTM(5:6)];



    clear lat lon

    fclose(nav)
    return

    
end

