 clear all

% *********************************************************************
% Get User specified data ranges
% *********************************************************************

startDate = '2017-05-01';
startTime = '0130:00';

% % ----- prompt user whether to plot submerged only
wetFlag =1;

% % ----- prompt user whether to plot latest data only
useLatest=1;

%This section prompts the user to tell us how many drifters he is plotting
NumDrifters=3;

%This section lets the user pick which drifter he wants to plot
DrifterPlot=zeros(1,6);
DrifterPlot(1,1:3)=1;
PrimaryDrifter=1;

% *************************************************************************
%   Load in coastline, CALCOFI and first web page
% *************************************************************************

% load in map data
%coastline=load('CRDcoastline.dat');
coastline=load('32183.dat');
load('P1206Cycles.mat');
load('CCStationPos.mat');
land=zeros(1,1);


%Opening Drifter Data Files - They should be csv files with all parameters
%(may have to be opened and resaved in excel)
endTime = datestr(now,13);
endTime = [endTime(1:2) endTime(4:8)];
endDate = datestr(now,29);


% *************************************************************************
%   Load in coastline, CALCOFI
% *************************************************************************

tic
% load in map data
land=zeros(1,1);
toc
% pause4

% *************************************************************************
% Prep and plot drifter data
% *************************************************************************
scrsz = get(0,'ScreenSize');
hMain = figure('Position',[30 30 .85*scrsz(3) .85*scrsz(4)],'resize','off','toolbar','figure');
% hMain = figure('Position',[30 30 .9*scrsz(3)
% .8*scrsz(4)],'resize','off');
hAxes = axes('Parent',hMain,'position',[.45 .1 .5 .8]);
% hAxes = axes('Parent',hMain,'position',[.4 .1 .55 .8]);
hTitle = title('Accessing website data ...','fontSize',25,'fontweight','bold','backgroundcolor','y')
hD1H = uicontrol('parent',hMain,'units','normalized','position',[.05 .96 .3 .05],...
    'style','text','fontsize',20,'fontweight','bold','string','Sediment Trap', ...
    'backgroundcolor','b','fontWeight','bold');
hD1L = uicontrol('parent',hMain,'units','normalized','position',[.05 .84 .3 .12],...
    'style','text','fontsize',15,'fontweight','normal','string','latlon');
hD1T = uicontrol('parent',hMain,'units','normalized','position',[.05 .76 .3 .08],...
    'style','text','fontsize',15,'fontweight','normal','string','time');
hD2H = uicontrol('parent',hMain,'units','normalized','position',[.05 .68 .3 .06],...
    'style','text','fontsize',20,'fontweight','bold','string','Wire Walker', ...
    'backgroundcolor','m','fontWeight','bold');
hD2L = uicontrol('parent',hMain,'units','normalized','position',[.05 .56 .3 .12],...
    'style','text','fontsize',15,'fontweight','normal','string','latlon');
hD2T = uicontrol('parent',hMain,'units','normalized','position',[.05 .48 .3 .08],...
    'style','text','fontsize',15,'fontweight','normal','string','time');
hD3H = uicontrol('parent',hMain,'units','normalized','position',[.05 .40 .3 .06],...
    'style','text','fontsize',20,'fontweight','bold','string','Drifter',...
    'backgroundcolor','r','fontWeight','bold');
hD3L = uicontrol('parent',hMain,'units','normalized','position',[.05 .28 .3 .12],...
    'style','text','fontsize',15,'fontweight','normal','string','latlon');
hD3T = uicontrol('parent',hMain,'units','normalized','position',[.05 .20 .3 .08],...
    'style','text','fontsize',15,'fontweight','normal','string','time');
hD4H = uicontrol('parent',hMain,'units','normalized','position',[.05 .12 .3 .06],...
    'style','text','fontsize',20,'fontweight','bold','string','Ship Position',...
    'backgroundcolor','g','fontWeight','bold');
hD4L = uicontrol('parent',hMain,'units','normalized','position',[.05 .01 .3 .12],...
    'style','text','fontsize',15,'fontweight','normal','string','latlon');
hD4T = uicontrol('parent',hMain,'units','normalized','position',[.05 .01 .3 .08],...
    'style','text','fontsize',15,'fontweight','normal','string','time');

% ----- prep figure
lonmin = -100;
lonmax = -80;
latmin = 12;
latmax = 32;
xlim([lonmin lonmax]);
ylim([latmin latmax]);

% read in initial nav string
%[latDD lonDD UTM]=ReadNAVdrifter;
shipLat = [32.53];
shipLon = [-80.999];

% *************************************************************************
%   Start main processing and auto update loop
% *************************************************************************

for loop=1:100000

    figure(hMain)
    hTitle = title('Accessing website data ...','fontSize',25,'fontweight','bold','backgroundcolor','y')
    % ----- get latest drifter data
    [deviceNum,serialTime,datLat,datLon,battVolt,gpsQual,subFlag,...
        pos1,pos3,pos4,time1,time3,time4] = getLatestWebData(startDate,startTime,endDate,endTime);

    % ------ save data for test dataset
    save testWebData deviceNum serialTime datLat datLon battVolt gpsQual subFlag ...
        pos1 pos3 pos4 time1 time3 time4

    % ------ Load test data instead of latest web data
%     load testWebData

    % ----- TEST
    subFlag(:)=1;


    % ----estimate range and bearing
    %  [RANGE,AF,AR]=DIST(LAT,LONG)
    lastSed= max(find(deviceNum==3));
    lastDrift1 = max(find(deviceNum==1));     %Drift Array
%     lastShip = max(find(deviceNum==4));
%     [rangeShipToSed, AF1, AR1]=dist([datLat(lastShip,1) datLat(lastSed,1)],[datLon(lastShip,1) datLon(lastSed,1)]);
%     [rangeShipToDrift, AF2, AR2]=dist([datLat(lastShip,1) datLat(lastDrift1,1)],[datLon(lastShip,1) datLon(lastDrift1,1)]);
    [rangeShipToSed, AF1]=distance(latDD, lonDD, datLat(lastSed,1), datLon(lastSed,1));
    [rangeShipToDrift, AF2]=distance(latDD, lonDD, datLat(lastDrift1,1), datLon(lastDrift1,1));
    rangeShipToSed = deg2km(rangeShipToSed);
    rangeShipToDrift = deg2km(rangeShipToDrift);


    % ----- set latest pos and time strings in figure
    set(hD1L,'string',pos1)
    set(hD1T,'string',time1)
    set(hD2L,'string',pos4)
    set(hD2T,'string',time4)
    set(hD3L,'string',pos3)
    set(hD3T,'string',time3)
    set(hD4L,'string',[num2str(latDD) '   ' num2str(lonDD)])
    set(hD4T,'string',UTM)


    if  ~isempty(rangeShipToSed)
        if AF1<0
            AF1=AF1+360;
        end
        set(hD1L,'string',{pos1;['Range from Ship: ' num2str(rangeShipToSed) 'km'];...
            ['Bearing from Ship:  ' num2str(round(AF1))]});
    end


    if  ~isempty(rangeShipToDrift)
        if AF2<0
            AF2=AF2+360;
        end
        set(hD3L,'string',{pos3;['Range from Ship: ' num2str(rangeShipToDrift) 'km'];...
            ['  ' 'Bearing from Ship:  ' num2str(round(AF2))]});
    end

    % ----- set map limits and plot coast + CalCOFI
    xlimNow = get(hAxes,'xlim');
    ylimNow = get(hAxes,'ylim');
    cla(hAxes)
    axes(hAxes)
    plot(coastline(:,1),coastline(:,2),'-ok','MarkerSize',1)
    hold on
    plot(C1SedTrap(:,2),C1SedTrap(:,1),'k')
    plot(C1Drifter(:,2),C1Drifter(:,1),'k')
    plot(C2SedTrap(:,2),C2SedTrap(:,1),'k')
    plot(C2Drifter(:,2),C2Drifter(:,1),'k')
    plot(C3SedTrap(:,2),C3SedTrap(:,1),'k')
    plot(C3Drifter(:,2),C3Drifter(:,1),'k')
     plot(CCStationPos(:,1),CCStationPos(:,2),'.y')
%     plot(cycle1(:,2),cycle1(:,1),'.k','MarkerSize',1)
%     plot(cycle2(:,2),cycle2(:,1),'.k','MarkerSize',1)
%     plot(cycle3(:,2),cycle3(:,1),'.k','MarkerSize',1)
%     xlim([lonmin lonmax]);
%     ylim([latmin latmax]);
    set(hAxes,'xlim',xlimNow,'ylim',ylimNow);

    % ----- plot drifter tracks
    axes(hAxes)
    hold on
    for loopOut = 1:5

    for loop2=1:3
%         for loop2=1:2
%         for loop2=1:1

    %         driftIDs = [1 3 4];
            driftIDs = [3 1 0];    %Drift Array is the Middle
%             driftIDs = 3;
            if DrifterPlot(loop2)
                indexData = find(deviceNum==driftIDs(loop2));

                if ~isempty(indexData)

                    xlimNow = get(hAxes,'xlim');
                    ylimNow = get(hAxes,'ylim');

                    if wetFlag
                        indexWet = find(subFlag==1);
                        indexData=intersect(indexWet,indexData);    % only grab submerged data from that
                    end

                    if loop2==1 % deviceNum=1 (sed trap) set color to blue
                        hPlotA1 = plot(hAxes,datLon(indexData,1),datLat(indexData,1),'-b');
                        hPlotB1 = plot(hAxes,datLon(indexData,1),datLat(indexData,1),'.',...
                            'MarkerSize',15,'MarkerFaceColor','b','MarkerEdgeColor','b');
                        hPlotC1 = plot(hAxes,datLon(indexData(end),1),datLat(indexData(end),1),...
                        'pr','MarkerSize',15,'MarkerFaceColor','b','MarkerEdgeColor','r');
                    elseif loop2==2 % deviceNum=2 (primary drifter) set color to red
                        hPlotA2 = plot(hAxes,datLon(indexData,1),datLat(indexData,1),'-r');
                        hPlotB2 = plot(hAxes,datLon(indexData,1),datLat(indexData,1),'.',...
                            'MarkerSize',15,'MarkerFaceColor','r','MarkerEdgeColor','r');
                        hPlotC2 = plot(hAxes,datLon(indexData(end),1),datLat(indexData(end),1),...
                        'pr','MarkerSize',15,'MarkerFaceColor','r','MarkerEdgeColor','r');
                    elseif loop2==3 % deviceNum=3 (wire walker) set color to red
                        hPlotA2 = plot(hAxes,datLon(indexData,1),datLat(indexData,1),'-m');
                        hPlotB2 = plot(hAxes,datLon(indexData,1),datLat(indexData,1),'.',...
                            'MarkerSize',15,'MarkerFaceColor','m','MarkerEdgeColor','m');
                        hPlotC2 = plot(hAxes,datLon(indexData(end),1),datLat(indexData(end),1),...
                        'pr','MarkerSize',15,'MarkerFaceColor','m','MarkerEdgeColor','m');
                    end

                    set(hAxes,'xlim',xlimNow,'ylim',ylimNow);

                end

                clear indexData


            end
        end

        try
            xlimNow = get(hAxes,'xlim');
            ylimNow = get(hAxes,'ylim');
            hPlotA3 = plot(hAxes,shipLon,shipLat,'-g');
            hPlotB3 = plot(hAxes,shipLon,shipLat,'.',...
                'MarkerSize',15,'MarkerFaceColor','g','MarkerEdgeColor','g');

            try
                if exist('hPlotC3')
                    delete(hPlotC3)
                end
            catch
            end
            hPlotC3 = plot(hAxes,lonDD,latDD,...
            'pr','MarkerSize',15,'MarkerFaceColor','g','MarkerEdgeColor','r');

            %[latDD lonDD UTM]=ReadNAVdrifter;
            %shipLat = [shipLat; latDD];
            %shipLon = [shipLon; lonDD];

            set(hD4L,'string',[num2str(latDD) '   ' num2str(lonDD)])
            set(hD4T,'string',UTM)
            set(hAxes,'xlim',xlimNow,'ylim',ylimNow)
            drawnow
            pause(5)

        catch
            lasterr
            keyboard
            title('Error Reading Nav Data ...Re-attempting','fontSize',25,'fontweight','bold','backgroundcolor','y')
        end
        pause(55)
    end

    title('Drifter Positions','fontSize',25,'fontweight','bold')
%     set(hAxes,'DataAspectRatioMode','manual','DataAspectRatioMode',[1.22 1 1],'PlotBoxAspectRatioMode','manual')
    hold off

%     pause(300)
    title('Accessing website data ...','fontSize',25,'fontweight','bold','backgroundcolor','y')
    disp(loop)

end
