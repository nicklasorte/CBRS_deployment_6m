function [list_cbsd_azi]=randomize_catB_rev1(app,eirp,cbsd_list_census,lower_ant_height_m,upper_ant_height_m)

tic;
%%%%%Generate CBSDs
% CAT B: Other Parameters
chan_scaling=0.1; %Channel Scaling 10 Percent
catb_urb_user_ap=200; %Number of Users per AP-Urban
catb_sub_user_ap=200; %Number of Users per AP-Suburban
catb_rur_user_ap=500; %Number of Users per AP-Rural

mark_pen=0.2; % Market Penetration 20 Percent
urb_comm_adjust=1.31; %Daytime Commuter Adjustment-Urban
comm_adjust=1; %Daytime Commuter Adjustment-Suburban/Rural

%Percentage Served Cat A vs Cat B
urb_served=0.8; % 80 Percent served by category A
sub_served=0.6; % 60 Percent served by category A
rur_served=0.4; % 40 Percent served by category A
%Remaining are served by Cat B


%%%%%%%%For each Census Tract, generate CBSDs,
load('new_all_geo_id_2010.mat','new_all_geo_id_2010')
load('ds_census_lat_2010.mat','ds_census_lat_2010')
load('ds_census_lon_2010.mat','ds_census_lon_2010')


%%%%%%%1)Geo Id, 2) Center Lat, 3)Center Lon, 4) NLCD (1-4), 5) Population
num_rows=length(cbsd_list_census(:,1));
cell_list_cbsd=cell(num_rows,1);
for i=1:1:num_rows
    census_geo_id=cbsd_list_census(i,1);
    census_track_idx=find(new_all_geo_id_2010==census_geo_id);
    
    if ~isempty(census_track_idx)==1
        temp_lat=ds_census_lat_2010{census_track_idx};
        temp_lat=temp_lat(~isnan(temp_lat));
        
        temp_lon=ds_census_lon_2010{census_track_idx};
        temp_lon=temp_lon(~isnan(temp_lon));
        
        temp_single_tract=horzcat(temp_lat,temp_lon); %%%Temp Census Shapefiles
        temp_pop=cbsd_list_census(i,5); %%%%%%Temp Population
        temp_land=cbsd_list_census(i,4); %%%%Temp Land Usage
        
        if temp_pop>0 %%%%%Check for Zero Population
            if length(temp_single_tract)>4
                if temp_land==4 %'dense urban'
                    temp_users=ceil((temp_pop*mark_pen*chan_scaling*urb_comm_adjust)); %Number of Users
                    catb_temp_ap=ceil(temp_users*(1-urb_served)/catb_urb_user_ap); %Number of Cat B Access Points
                elseif temp_land==3  %'Urban'
                    temp_users=ceil((temp_pop*mark_pen*chan_scaling*urb_comm_adjust)); %Number of Users
                    catb_temp_ap=ceil(temp_users*(1-urb_served)/catb_urb_user_ap); %Number of Cat B Access Points
                elseif temp_land==2   %'Suburban'
                    temp_users=ceil((temp_pop*mark_pen*chan_scaling*comm_adjust)); %Number of Suburan Users
                    catb_temp_ap=ceil(temp_users*(1-sub_served)/catb_sub_user_ap); %Number of Cat B Access Points
                elseif temp_land==1  %'Rural'
                    temp_users=ceil((temp_pop*mark_pen*chan_scaling*comm_adjust)); %Number of Rural Users
                    catb_temp_ap=ceil(temp_users*(1-rur_served)/catb_rur_user_ap); %Number of Cat B Access Points
                end                
                
                temp_list_cbsd=NaN(catb_temp_ap,9);
                temp_list_cbsd(:,4)=temp_land;
                temp_list_cbsd(:,9)=temp_pop;
                for k=1:1:catb_temp_ap %%%Generate CBSD within the Census Tract
                    [lat_pt,lon_pt]=gen_lat_lon_census_app(app,temp_single_tract);
                    temp_list_cbsd(k,1)=lat_pt;
                    temp_list_cbsd(k,2)=lon_pt;
                end
                cell_list_cbsd{i}=temp_list_cbsd;
            end
        end        
    end
end


list_cbsd=vertcat(cell_list_cbsd{:});
[num_cbsd,~]=size(list_cbsd);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Antenna Height
ant_rand=rand(num_cbsd,1); %Randomization for Antenna Height and Lat/Lon
list_cbsd(:,3)=round((upper_ant_height_m-lower_ant_height_m)*(ant_rand)+lower_ant_height_m);  

%%%%EIRP
list_cbsd(:,5)=eirp;

%%%%%%%%%%%%For CatB CBSDs, include Azimuth
azi_rand=round(rand(num_cbsd,1)*360);
three_azi=mod(horzcat(azi_rand,azi_rand+120,azi_rand+240),360); %%%Three Azimuths
list_cbsd(:,6:8)=three_azi;
[~,idx_sort] = sort(list_cbsd(:,9),'descend'); %Sort Based upon Population
list_cbsd_azi=list_cbsd(idx_sort,:);
toc;

end