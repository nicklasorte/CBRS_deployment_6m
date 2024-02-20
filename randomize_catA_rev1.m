function [list_cbsd_azi]=randomize_catA_rev1(app,eirp,cbsd_list_census,lower_ant_height_m,upper_ant_height_m)


tic;
% CAT A: Other Parameters
mark_pen=0.2; % Market Penetration 20 Percent
chan_scaling=0.1; %Channel Scaling 10 Percent
urb_comm_adjust=1.31; %Daytime Commuter Adjustment-Urban
comm_adjust=1; %Daytime Commuter Adjustment-Suburban/Rural
urb_user_ap=50; %Number of Users per AP-Urban
sub_user_ap=20; %Number of Users per AP-Suburban
rur_user_ap=3; %Number of Users per AP-Rural

%Percentage Served Cat A vs Cat B
urb_served=0.8; % 80 Percent served by category A
sub_served=0.6; % 60 Percent served by category A
rur_served=0.4; % 40 Percent served by category A
%Remaining are served by Cat B


% Place APs due to a Uniform Distribution, some APs will land outside of tract.
load('new_all_geo_id_2010.mat','new_all_geo_id_2010')
load('ds_census_lat_2010.mat','ds_census_lat_2010')
load('ds_census_lon_2010.mat','ds_census_lon_2010')


num_rows=length(cbsd_list_census(:,1));
cell_list_cbsd=cell(num_rows,1);
for i=1:1:num_rows
    census_geo_id=cbsd_list_census(i,1);
    census_track_idx=find(new_all_geo_id_2010==census_geo_id);
    
    if ~isempty(census_track_idx)==1
        %temp_lat=new_census_lat_2010{census_track_idx}';
        temp_lat=ds_census_lat_2010{census_track_idx};
        temp_lat=temp_lat(~isnan(temp_lat));
        
        %temp_lon=new_census_lon_2010{census_track_idx}';
        temp_lon=ds_census_lon_2010{census_track_idx};
        temp_lon=temp_lon(~isnan(temp_lon));
        
        temp_single_tract=horzcat(temp_lat,temp_lon); %%%Temp Census Shapefiles
        temp_pop=cbsd_list_census(i,5); %%%%%%Temp Population
        temp_land=cbsd_list_census(i,4); %%%%Temp Land Usage

        if temp_pop>0 %%%%%Check for Zero Population
            if length(temp_single_tract)>4
                if temp_land==4 %'dense urban'
                    temp_users=ceil((temp_pop*mark_pen*chan_scaling*urb_comm_adjust)); %Number of Users
                    cata_temp_ap=ceil(temp_users*urb_served/(urb_user_ap)); %Number of Cat A Access Points
                elseif temp_land==3  %'Urban'
                    temp_users=ceil((temp_pop*mark_pen*chan_scaling*urb_comm_adjust)); %Number of Users
                    cata_temp_ap=ceil(temp_users*urb_served/(urb_user_ap)); %Number of Cat A Access Points
                elseif temp_land==2   %'Suburban'
                    temp_users=ceil((temp_pop*mark_pen*chan_scaling*comm_adjust)); %Number of Suburan Users
                    cata_temp_ap=ceil(temp_users*sub_served/(sub_user_ap)); %Number of Cat A Access Points
                elseif temp_land==1  %'Rural'
                    temp_users=ceil((temp_pop*mark_pen*chan_scaling*comm_adjust)); %Number of Suburan Users
                    cata_temp_ap=ceil(temp_users*rur_served/(rur_user_ap)); %Number of Cat A Access Points
                end
                
                temp_list_cbsd_cata=NaN(cata_temp_ap,9);
                temp_list_cbsd_cata(:,4)=temp_land;
                temp_list_cbsd_cata(:,9)=temp_pop;
                for k=1:1:cata_temp_ap %%%Generate CBSD within the Census Tract
                    [lat_pt,lon_pt]=gen_lat_lon_census_app(app,temp_single_tract);
                    temp_list_cbsd_cata(k,1)=lat_pt;
                    temp_list_cbsd_cata(k,2)=lon_pt;
                end
                cell_list_cbsd{i}=temp_list_cbsd_cata;  
            end
        end
    end
end


list_cbsd_cata=vertcat(cell_list_cbsd{:});
[num_cbsd,~]=size(list_cbsd_cata); 

%%%%%Antenna Height
ant_rand=rand(num_cbsd,1); %Randomization for Antenna Height and Lat/Lon
list_cbsd_cata(:,3)=round((upper_ant_height_m-lower_ant_height_m)*(ant_rand)+lower_ant_height_m);  

%%%%EIRP
list_cbsd_cata(:,5)=eirp;
%%%%%%%%list_cbsd_cata(:,6:8)=NaN(1); %NaN equates to an omni directional antenna
[~,idx_sort] = sort(list_cbsd_cata(:,9),'descend'); %Sort Based upon Population

list_cbsd_azi=list_cbsd_cata(idx_sort,:);
toc;
end