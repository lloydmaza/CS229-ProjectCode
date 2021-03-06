% Script to run basic CGLA implementation
clear
close all
clc

tic

%Initializes all the threats, uavs, and targets
[UAVs, threats, targets, n] = scenario5();
K = .25E3;

tic
% Run the simulation while any UAVs are active
numIt = 1;

while any(cellfun(@(c) c.state.active, UAVs)) && numIt < 50
    
    [updatedFlag, threats] = checkForThreats(UAVs, threats);
    
    if UAVs{1}.state.active == 0
       help = 'breakpoint'; 
    end
    if numIt == 1
        updatedFlag = true;
    end
    
    if updatedFlag
        
        A = computeWeightMatrix(n, threats, K);
        UAVs = updateTargets(UAVs, targets, A);
        UAVs = computeCostMatrix(UAVs, A, targets);
        
        UAVs = updatePaths(UAVs, targets);
        
    end
    
    [UAVs, uavStop, targets] = updateStates(UAVs, targets);
    if uavStop
        UAVs = updateTargets(UAVs, targets, A);
        UAVs = computeCostMatrix(UAVs, A, targets);
        UAVs = updatePaths(UAVs, targets);
        numUavs = size(UAVs, 2);
        for i = 1:numUavs
            if UAVs{i}.trait.target == 1
                UAVs{i}.state.active = false;
            end
        end
    end
    numIt = numIt + 1
    if numIt == 15
        help = 'breakpoint here';
    end
    
end

% Plot the threats
f = plotThreats(n, threats);
hold on

% Plot the optimal path and the target
for ii = 1:length(UAVs)
    
    uavX = UAVs{ii}.trait.stateHistory(:, 1);
    uavY = UAVs{ii}.trait.stateHistory(:, 2);
    
%     plot(uavX./n, uavY./n, 'k', 'LineWidth', 1.5);
    plot(uavX./n, uavY./n, 'k');
    hold on
    plot(uavX(1)./n, uavY(2)./n, 'or', 'MarkerFaceColor', 'r');
    
end

% Ignore the first target (home base)
for jj = 2:length(targets)
    
    targX = targets{jj}.state.x;
    targY = targets{jj}.state.y;
    
    
    plot(targX/n, targY/n, 'ob', 'MarkerFaceColor', 'b');
    
end

% xlabel('x');
% ylabel('y');
% axis(n*[0, 1, 0, 1]);
%
% % Plot level curves on the threats
% [X, Y] = meshgrid(linspace(1, n, 10*n)); %// all combinations of x, y
%
% Z = zeros(size(X));
% for ii = 1:length(threats)
%
%     mu = [threats{ii}.state.x, threats{ii}.state.y];
%     sigma = threats{ii}.trait.cov;
%
%     Zi = mvnpdf([X(:) Y(:)], mu, sigma);
%     Zi = reshape(Zi, size(X));
%     Z = Z + Zi;
%
% end
%
% contour(X, Y, Z);
%
% axis equal
% grid on

toc