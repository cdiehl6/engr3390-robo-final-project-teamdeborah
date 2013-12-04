%% main.m
% This code interprets data gathered from the boat to discover some of the
% boat dynamics. Two major aspects of the boat are revealed in this script:
%   - With a constant rudder angle, the boats travel in a circle
%   - The curvature of the boat's path is proportional to the rudder angle
%    (i.e) the radius of the circle is inversely proportional to the rudder
%    angle

function slope = main
    %% Fit Boat Trajectories to Circles
    % Preallocate Memory
    turnRad = zeros(1,15);
    figure

    % Extract the data from each of the files
    filename = 'rudder_test';    
    for i=1:15
        if i==8
            % No data exists for 'rudder_test7.csv'
            turnRad(i) = 0;
            continue
        end
        
        % extract data
        BoatData = csvread(strcat(filename, num2str(i-1),'.csv'),3,0);
        x = BoatData(:,1);
        y = BoatData(:,2);
        
        % fit circle
        [xc,yc,turnRad(i)] = circfit(x,y);
        
        % plot data
        plot(x-xc,y-yc,'.'); hold on
        axis equal
        plotCirc(0,0,turnRad(i))
    end
    
    % annotate the diagram
    title('Boat Trajectories','fontsize',14)
    xlabel('X (Pixels)','fontsize',12); ylabel('Y (Pixels)','fontsize',12)
    legend('Trajectory Data','Circle Fit');
    
    %% Map Rudder Angle to Curvature 1/(Turn Radius) 
    % get the rudder angle data
    AngleMap = csvread('angles.csv',1,0);
    
    % plot rudder command against turn radius
    figure
    plot([AngleMap(1:7,2)' AngleMap(9:15,2)'], 1./[turnRad(1:7) turnRad(9:15)],'.');
    hold on
    
    % fit the first half of angles 90-135
    rud1 = AngleMap(1:7,2)';
    [P1,~] = polyfit(rud1, 1./turnRad(1:7), 1);
    curv1 = P1(2) + rud1*P1(1);
    plot(rud1,curv1,'r')
    
    % fit the second half of angles 45-90
    rud2 = AngleMap(9:15,2)';
    [P2,~] = polyfit(rud2, 1./turnRad(9:15), 1);
    curv2 = P2(2) + rud2*P2(1);
    plot(rud2,curv2,'r')
    
    % annotate the figure
    title('Trajectory Curvature v Rudder Angle', 'fontsize', 14)
    xlabel('Rudder Angle (Degrees)', 'fontsize', 12); ylabel('Path Curvature (1/Pixels)', 'fontsize', 12)
    legend('Curvature Data','Linear Fit')
    
    % calculate and plot the error
    figure
    err = [curv1-1./turnRad(1:7) curv2-1./turnRad(9:15)];
    plot([rud1 rud2],err,'.')
    title('Linear Fit Error', 'fontsize', 14)
    xlabel('Rudder Angle (Degrees)', 'fontsize', 12); ylabel('Error (1/Pixels)', 'fontsize', 12)
    
    % return the average slope of the line
    slope = mean([P1(1) P2(1)]);
    
end

%% Plot a Circle
function plotCirc(xc,yc,r)
    theta = linspace(0,2*pi);
    x = r*cos(theta) + xc;
    y = r*sin(theta) + yc;
    plot(x,y,'r');
end