function plotMF(StrategyType,FolderName)

%% Debug Enable Commands
%debug_on_warning(1);
%debug_on_error(1);

% Assing appropriate directoy based on Ctrl Strategy 
if StrategyType=='S'
	StratTypeFolder = 'PositionControl/StraightLineApproach-NewIKinParams/';				% Straight Line with new IKin params
elseif StrategyType=='SN'
	StratTypeFolder = 'PositionControl/StraightLineApproach-NewIkinParams-Noise/';			% Straight Line with new IKin params with noise
elseif StrategyType=='P'
	StratTypeFolder = 'PositionControl/PivotApproach-NewIkinParams/';				% Pivot approach with new IKin Params
elseif StrategyType=='PN'
	StratTypeFolder = 'PositionControl/PivotApproach-NewIKin-Noise/';				% Pivot approach with new IKin Params with noise
elseif StrategyType=='FS'
	StratTypeFolder = 'ForceControl/StraightLineApproach/';
elseif StrategyType=='FP'
	StratTypeFolder = 'ForceControl/PivotApproach/';		
end

% Assign the right folder name
AngleData=strcat('/home/juan/Documents/Results/',StratTypeFolder,FolderName,'/Torques.dat');
ForceData=strcat('/home/juan/Documents/Results/',StratTypeFolder,FolderName,'/filtTorques.dat');
RotSpringData=strcat('/home/juan/Documents/Results/',StratTypeFolder,FolderName,'/RotSpring.dat');

%% Load the data
X=load(AngleData);
Y=load(ForceData);
Z=load(RotSpringData);

%% Plot Joint Angle Path (first 7 angles)
figure(1),
subplot(5,1,1),  J=plot(X(:,1), X(:,2:8));
title('Joint Angle Path'); xlabel('Time (secs)'); ylabel('Joint Angle (radians)');

% Max and min values
[x i]=min(min(X(1:length(X),2:8)));
[y i]=max(max(X(1:length(X),2:8)));

% Axis adjustment
%if(FolderName=='20120126-1159-PivotApproach-FullSnap')
 axis([X(1,1) X(length(X),1) x y])
%endif	 
 
%% Plot gripper Path (2 values)
subplot(5,1,2), G=plot(X(:,1), X(:,9:10));
title('Gripper Path'); xlabel('Time (secs)'); ylabel('Gripper Angle');

% Max and min values
[x i]=min(min(X(1:length(X),9:10)));
[y i]=max(max(X(1:length(X),9:10)));

% Axis adjustment
%if(FolderName=='20120126-1159-PivotApproach-FullSnap')
%axis([X(1,1) X(length(X),1) y-(0.02*x) x+(0.02*y)])
axis([X(1,1) X(length(X),1) x y])
%endif	 
 
%% Plot Rotation Spring Joint Position
subplot(5,1,3), S=plot(Z(:,1),Z(:,2:3) )
title('Snap Joint Position'); xlabel('Time (secs)'); ylabel('Joint Angle'); 

% Max and min values
[x i]=min(min(Z(1:length(Z),2:3)));
[y i]=max(max(Z(1:length(Z),2:3)));

% Axis adjustment
axis([Z(1,1) Z(length(Z),1) y-(0.02*x) x+(0.02*y)])
%if(FolderName=='20120126-1159-PivotApproach-FullSnap')
axis([Z(1,1) Z(length(Z),1) x y])
%endif	 
legend ('Snap1','Snap2','location','NorthEastOutside');

%% Plot Force
subplot(5,1,4),F=plot(Y(:,1),Y(:,2:4));
title('Force Plot'); xlabel('Time (secs)'); ylabel('Force (N)')

% Max and min values
[x i]=min(min(Y(1:length(Y),2:4))); %we want to find the max and min value in the area of contact not before that.
[y i]=max(max(Y(1:length(Y),2:4)));

% Adjust axis
%axis([Y(1,1) Y(length(Y),1) y-(0.02*x) x+(0.02*y)])
%if(FolderName=='20120126-1159-PivotApproach-FullSnap')
axis([Y(1,1) Y(length(Y),1) 0.6*x 0.6*y])
%endif


%% Plot Moment
subplot(5,1,5), M=plot(Y(:,1),Y(:,5:7));
title('Moment Plot'); xlabel('Time (secs)'); ylabel('Moment (N-m)');

% Max and min values
[x i]=min(min(Y(1:length(Y),5:7)));
[y i]=max(max(Y(1:length(Y),5:7)));

% Adjust axis
%axis([Y(1,1) Y(length(Y),1) y-(0.02*x) x+(0.02*y)])
%if(FolderName=='20120126-1159-PivotApproach-FullSnap')
axis([Y(1,1) Y(length(Y),1) 0.6*x 0.6*y])
%endif
legend ('Tx','Ty','Tz','location','NorthEastOutside');

% Save plot to file
print -deps Multiplot.eps;
print -dfig   Multiplot.fig;
print -dpng Multiplot.png;