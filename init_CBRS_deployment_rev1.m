clear;
clc;
close all;
close all force;
app=NaN(1);  %%%%%%%%This is for me and APPs
format shortG
top_start_clock=clock;
folder1='C:\Local Matlab Data\3.5GHz Mod Deployment'  %%%%%Folder where all the matlab code is placed.
cd(folder1)
addpath(folder1)

%%%%%%%%%%%%%%%%%%%%%%Code for CBRS Deployment (modified to test the 6m antenna height)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%Load in the DPAs.
load('cell_e_dpa_data.mat','cell_e_dpa_data')
load('cell_p_dpa_data.mat','cell_p_dpa_data')

% % % %%%%%%%%%%%%%%%Same as E-DPA/P-DPA
% % % 1) Name,
% % % 2) Lat
% % % 3) Lon,
% % % 4) Radar Threshold,
% % % 5) Radar Height,
% % % 6) Radar Beamwidth,
% % % 7) Min Azimuth
% % % 8) Max Azimuth
% % % 9) CatB Above 6m dist
% % % 10) CatB Below 6m dist
% % % 11) CatA inside Above 6m dist
% % % 12) CatA inside Below 6m dist
% % % 13) Low Freq
% % % 14) High Freq
% % % 15) Cell Geometry
% % % 16) CatA Outdoor Above 6m dist
% % % 17) CatA Outdoor Below 6m dist

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Creating a Simulation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Make a Simulation Folder
rev=100; %%%%%%East 1 Example : E-DPA
dpa_name_idx=find(matches(cell_e_dpa_data(:,1),'East1'))
cell_dpa_data=cell_e_dpa_data(dpa_name_idx,:)
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % rev=101; %%%%%%Moorestown Example : P-DPA
% % dpa_name_idx=find(matches(cell_p_dpa_data(:,1),'MOORESTOWN'))
% % cell_dpa_data=cell_p_dpa_data(dpa_name_idx,:)
% % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Create a Folder to Put all the Files in
cd(folder1);
pause(0.1)
tempfolder=strcat('Rev',num2str(rev));
[status,msg,msgID]=mkdir(tempfolder);
rev_folder=fullfile(folder1,tempfolder);
cd(rev_folder)
pause(0.1)

[full_list_catb,full_list_cata]=cbrs_deployment_rev1(app,rev,cell_dpa_data);

cd(folder1)
pause(0.1)

end_clock=clock;
total_clock=end_clock-top_start_clock;
total_seconds=total_clock(6)+total_clock(5)*60+total_clock(4)*3600+total_clock(3)*86400;
total_mins=total_seconds/60;
total_hours=total_mins/60;
if total_hours>1
    strcat('Total Hours:',num2str(total_hours))
elseif total_mins>1
    strcat('Total Minutes:',num2str(total_mins))
else
    strcat('Total Seconds:',num2str(total_seconds))
end



