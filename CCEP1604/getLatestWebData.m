function [deviceNum,serialTime,datLat,datLon,battVolt,gpsQual,submergeFlag, ...
    pos1,pos3,pos4,time1,time3,time4] = getLatestWebData(startDate,startTime,endDate,endTime);

% ----- load latest data from web
startDate = '2011-06-18';   %for testing
startTime = '0130:00';
endDate = datestr(now,13);
endTime = [endDate(1:2) endDate(4:8)];
% tic
while 1
    try
        s = urlread('http://api.pacificgyre.com/api/Getdata.aspx?uid=ohman&pwd=bottlechain&showheader=true&reportid=3&reportstyleid=1&devicelist=0&startdate=07/15/2011%2023:59&enddate=09/01/2011%2023:59');
    break
    catch
        disp('Failed to connect to internet. Retrying ....')
        pause(30)
    end
    pause(5)
end
% toc
C=textscan(s,'%s %s %s %d %d %n %n %n %n %n %n','headerlines',1, 'delimiter', ',', 'whitespace', '');

% % ----- load test data when web is down
% fid = fopen('testDataFromWeb2.txt'); 
% C=textscan(fid,'%s %s %s %d %d %n %n %n %n %n','headerlines',1, 'delimiter', ',', 'whitespace', '');
% fclose(fid)

deviceName = char(C{1,1});
deviceTime = char(C{1,2});
datLat = C{1,6};
datLon = C{1,7};
battVolt = C{1,9};
gpsQual = C{1,5};
submergeFlag=C{1,10};

%----- set zero lats and lons to nan
indexZeroLat = find(datLat==0);
datLat(indexZeroLat,1) = nan;
indexZeroLon = find(datLon==0);

% extract device number from devicename
% keyboard
deviceNum = str2num(deviceName(:,11));
datLon(indexZeroLon,1)=nan;

% ----- get serialTime
% serialTime = datenum(deviceTime,31);  %DOES NOT WORK ON MAC
serialTime=0;
for loop=1:size(datLat,1)
    tempTime = deviceTime(loop,:);
    YY = str2double(tempTime(1:4));
    MM = str2double(tempTime(6:7));
    DD = str2double(tempTime(9:10));
    HH = str2double(tempTime(12:13));
    Mi = str2double(tempTime(15:16));
    SS = str2double(tempTime(18:19));
    serialTime(loop,1)= datenum([YY,MM,DD,HH,Mi,SS]);
end




% ----- hack to remove dates < 03 Oct 2008
indexGoodDate = find(serialTime>=733685.35);
deviceName = deviceName(indexGoodDate,:);
deviceTime = deviceTime(indexGoodDate,:);
datLat = datLat(indexGoodDate,:);
datLon = datLon(indexGoodDate,:);
battVolt = battVolt(indexGoodDate,:);
gpsQual = gpsQual(indexGoodDate,:);
submergeFlag= submergeFlag(indexGoodDate,:);
serialTime = serialTime(indexGoodDate,:);
deviceNum = deviceNum(indexGoodDate,:);

% ---- hack for bad GPS fix on sed trap
%     badGPSdata = [33.4086 -122.340144]; % add rows to this as bad GPS
%     appears
badGPSdata = [33.641519 -121.191385 4]; % add rows to this as bad GPS
for fixLoop=1:size(badGPSdata,1);
    hackIndex = find(deviceNum==badGPSdata(fixLoop,3));
    hackLat = find(datLat==badGPSdata(fixLoop,1));
    hackLon = find(datLon==badGPSdata(fixLoop,2));
    hackLatLon = intersect(hackLat, hackLon);
    hackBadData = intersect(hackLatLon,hackIndex);
    if isempty(hackIndex) | isempty(hackBadData)
        break
    end
    
    hackIndexPos= find(hackIndex==hackBadData);
    
    if ~isempty(hackBadData)
        % set bad gps fixs to last previous fix
        hackGoodData = setdiff([1:size(deviceNum,1)],hackBadData);
        deviceName=deviceName(hackGoodData,:);
        deviceTime=deviceTime(hackGoodData,:);
        datLat=datLat(hackGoodData,:);
        datLon=datLon(hackGoodData,:);
        battVolt=battVolt(hackGoodData,:);
        gpsQual=gpsQual(hackGoodData,:);
        submergeFlag=submergeFlag(hackGoodData,:);
        serialTime=serialTime(hackGoodData,:);
        deviceNum=deviceNum(hackGoodData,:);
    end
    clear hackBadData
%     datLat(hackBadData,1)=datLat(hackIndex(hackIndexPos-1),1);
%     datLon(hackBadData,1)=datLon(hackIndex(hackIndexPos-1),1);
end

% ---- sort rows by device and time
[tempY indexSort] = sortrows([deviceNum serialTime],[1 2]);
deviceNum = deviceNum(indexSort,1);
serialTime = serialTime(indexSort,1);
datLat = datLat(indexSort,1);
datLon = datLon(indexSort,1);
gpsQual = gpsQual(indexSort,1);
battVolt = battVolt(indexSort,1);

% ---- remove rows where Lat or Lon = 0.0
indexZeroLat = union(find(datLat==0),find(isnan(datLat)));
indexZeroLon = union(find(datLon==0),find(isnan(datLon)));
indexZeroPos = union(indexZeroLat,indexZeroLon);
if ~isempty(indexZeroPos)
    indexGoodPos = setdiff([1:size(datLat,1)],indexZeroPos);
    deviceName=deviceName(indexGoodPos,:);
    deviceTime=deviceTime(indexGoodPos,:);
    datLat=datLat(indexGoodPos,:);
    datLon=datLon(indexGoodPos,:);
    battVolt=battVolt(indexGoodPos,:);
    gpsQual=gpsQual(indexGoodPos,:);
    submergeFlag=submergeFlag(indexGoodPos,:);
    serialTime=serialTime(indexGoodPos,:);
    deviceNum=deviceNum(indexGoodPos,:);
end

% ---- remove duplicate rows
[B,indexUnique,J] = unique([deviceNum serialTime datLat datLon],'rows');
% keyboard
if ~isempty(indexUnique)
    deviceName=deviceName(indexUnique,:);
    deviceTime=deviceTime(indexUnique,:);
    datLat=datLat(indexUnique,:);
    datLon=datLon(indexUnique,:);
    battVolt=battVolt(indexUnique,:);
    gpsQual=gpsQual(indexUnique,:);
    submergeFlag=submergeFlag(indexUnique,:);
    serialTime=serialTime(indexUnique,:);
    deviceNum=deviceNum(indexUnique,:);
end

% ---- get latest position and time for drifters
index1 = find(deviceNum==3);
index3 = find(deviceNum==1);   %Drift Array
index4 = find(deviceNum==0);
        % NOTE: The dvice number needs to be changed when different
        % drifters are swapped. Can I make more user confgurable, more
        % transparent.

if ~isempty(index1)
    pos1 = [num2str(datLat(index1(end))) '      ' num2str(datLon(index1(end)))];
    time1 = [datestr(serialTime(index1(end)),31) ' GMT'];
else
    pos1 = 'Not Tracked';
    time1 = 'Not Tracked';
end

if ~isempty(index3)
    pos3 = [num2str(datLat(index3(end))) '      ' num2str(datLon(index3(end)))];
    time3 = [datestr(serialTime(index3(end)),31) ' GMT'];
else
    pos3 = 'Not Tracked';
    time3 = 'Not Tracked';
end

if ~isempty(index4)
    pos4 = [num2str(datLat(index4(end))) '      ' num2str(datLon(index4(end)))];
    time4 = [datestr(serialTime(index4(end)),31) ' GMT'];
else
    pos4 = 'I sucked.';
    time4 = 'So they got rid of me.';
end


return

% ********* web string format!!!! **************
% http://www.pacificgyre.com/api/Getdata.aspx?uid=ohman&pwd=bottlechain&showheader=true&reportid=3&reportstyleid=1&devicelist=0&startdate=2008-10-01%2000:00&enddate=2008-10-30%2020:23
    

%Opening Drifter Data Files - They should be csv files with all parameters
%     %(may have to be opened and resaved in excel)
%     endTime = datestr(now,13);
%     endTime = [endTime(1:2) endTime(4:8)];
%     while 1
%         try
%             s = urlread('http://www.pacificgyre.com/api/Getdata.aspx?uid=ohman&pwd=bottlechain&showheader=true&reportid=3&reportstyleid=1&devicelist=0&startdate=3/29/2007%2000:00&enddate=4/05/2007%2023:59');
%             % s = urlread(['http://www.pacificgyre.com/api/Getdata.aspx?uid=ohman&pwd=bottlechain&showheader=true&reportid=3&reportstyleid=1&devicelist=0&startdate=' startDate '%' startTime '&enddate=' datestr(now,29) '%' endTime]);
%         break
%         catch
%             disp('Failed to connect to internet. Retrying ....')
%         end
%     end
%     C=textscan(s,'%s %s %s %d %d %n %n %n %n %s','headerlines',1, 'delimiter', ',', 'whitespace', '');
