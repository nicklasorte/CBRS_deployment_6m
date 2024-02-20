function [full_list_catb,full_list_cata]=cbrs_deployment_rev1(app,rev,cell_dpa_data)

RandStream('mt19937ar','Seed','shuffle')
rng(rev); %%%%%%%%%%For Repeatability: Control random number generator


        catb_above6_km=cell_dpa_data{1,9};
        catb_below6_km=cell_dpa_data{1,10};
        cata_inside_above6_km=cell_dpa_data{1,11};
        catb_inside_below6_km=cell_dpa_data{1,12};
        dpa_lat=cell_dpa_data{1,2};
        dpa_lon=cell_dpa_data{1,3};
        dpa_latlon=horzcat(dpa_lat,dpa_lon);

        %%%%%%%%%%%%%%Step 1, Draw the Neighborhoods
        tic;
        [dpa_catB_above6_buffer]=latlon_buffer_rev1(app,dpa_latlon,catb_above6_km);
        [dpa_catB_below6_buffer]=latlon_buffer_rev1(app,dpa_latlon,catb_below6_km);
        [dpa_catA_above6_buffer]=latlon_buffer_rev1(app,dpa_latlon,cata_inside_above6_km);
        [dpa_catA_below6_buffer]=latlon_buffer_rev1(app,dpa_latlon,catb_inside_below6_km);
        toc;

        %%%%%%%%Filter Census Tracts
        tic;
        load('Cascade_new_full_census_2010.mat','new_full_census_2010')%%%%%%%Geo Id, Center Lat, Center Lon,  NLCD (1-4), Population
        [catB1_census_idx]=census_contour_filter_rev1(app,new_full_census_2010,dpa_catB_above6_buffer);
        [catB2_census_idx]=census_contour_filter_rev1(app,new_full_census_2010,dpa_catB_below6_buffer);
        [catA1_census_idx]=census_contour_filter_rev1(app,new_full_census_2010,dpa_catA_above6_buffer);
        [catA2_census_idx]=census_contour_filter_rev1(app,new_full_census_2010,dpa_catA_below6_buffer);
        toc;

        catB_above_list_census=new_full_census_2010(catB1_census_idx,:);
        catB_below_list_census=new_full_census_2010(catB2_census_idx,:);
        catA_above_list_census=new_full_census_2010(catA1_census_idx,:);
        catA_below_list_census=new_full_census_2010(catA2_census_idx,:);


%%%%%%%%%%%%%%CatB Above 6m
catB_eirp=47; %%%%%%%No Distribution for this one.
%%%%%%%%Antenna Height (Uniform Distirubtion)
lower_ant_height_m=7; %7 meters (Uniform Distirubtion)
upper_ant_height_m=30; %30 meters
[list_catB_above]=randomize_catB_rev1(app,catB_eirp,catB_above_list_census,lower_ant_height_m,upper_ant_height_m);

%%%%%%%%%%%CatB Below 6m
lower_ant_height_m=3; %meters (Uniform Distirubtion)
upper_ant_height_m=6; %meters
[list_catB_below]=randomize_catB_rev1(app,catB_eirp,catB_below_list_census,lower_ant_height_m,upper_ant_height_m);

%%%%%%%%%%%%%%%%%%%CatA Above 6m
catA_eirp=30;
lower_ant_height_m=7; %7 meters (Uniform Distirubtion)
upper_ant_height_m=30; %30 meters
[list_catA_above]=randomize_catA_rev1(app,catA_eirp,catA_above_list_census,lower_ant_height_m,upper_ant_height_m);

%%%%%%%%%%%%%%%%%%CatA Below 6m
lower_ant_height_m=3; %meters (Uniform Distirubtion)
upper_ant_height_m=6; %meters
[list_catA_below]=randomize_catA_rev1(app,catA_eirp,catA_below_list_census,lower_ant_height_m,upper_ant_height_m);

full_list_catb=vertcat(list_catB_above,list_catB_below);
full_list_cata=vertcat(list_catA_above,list_catA_below);
[num_catA,~]=size(full_list_cata);
full_list_cata(:,6)=1:1:num_catA; %%%%%Numbering the CatAs in one of the Azimuth Columns

if isempty(full_list_cata)==1
    full_list_cata=horzcat(dpa_latlon(1,:),6,1,30)
    'EMPTY CATA'
    %pause;
end

if isempty(full_list_catb)==1
    full_list_catb=horzcat(dpa_latlon(1,:),25,1,47)
    'EMPTY CATB'
    %pause;
end



    %%%%%1) Latitude Degree Decimal
    %%%%%2) Longitude Degree Decimal
    %%%%%3) Height (meters)
    %%%%%4) NLCD (1==Rural, 2== Suburban, 3==Urban, 4==Dense Urban)
    %%%%%5) EIRP (dBm/10MHz)
    %%%%%6-8) Randomized Antenna Azimuth (3 Sectors)
    %%%%%9) Population of Census Tract that the Base Station is within


save('full_list_catb.mat','full_list_catb');
save('full_list_cata.mat','full_list_cata');

size(full_list_cata)
size(full_list_catb)


table_catB=array2table(full_list_catb);
excel_filename_catB=strcat('CatB',num2str(rev),'_',cell_dpa_data{1,1},'.xlsx');
writetable(table_catB,excel_filename_catB)

table_catA=array2table(full_list_cata);
excel_filename_catA=strcat('CatA',num2str(rev),'_',cell_dpa_data{1,1},'.xlsx');
writetable(table_catA,excel_filename_catA)


close all;
figure
hold on;
plot(dpa_catB_above6_buffer(:,2),dpa_catB_above6_buffer(:,1),'--b','LineWidth',2)
plot(dpa_catB_below6_buffer(:,2),dpa_catB_below6_buffer(:,1),':r','LineWidth',2)
plot(dpa_catA_above6_buffer(:,2),dpa_catA_above6_buffer(:,1),'-g','LineWidth',2)
plot(dpa_catA_below6_buffer(:,2),dpa_catA_below6_buffer(:,1),'-k','LineWidth',2)
if length(dpa_latlon(:,1))==1
    plot(dpa_latlon(:,2),dpa_latlon(:,1),'ok')
else
    plot(dpa_latlon(:,2),dpa_latlon(:,1),'-k')
end
grid on;
ylabel('Latitude')
xlabel('Longitude')
title({'Deployment Area'})
plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
filename3=strcat('Step1.png');
saveas(gcf,char(filename3))
pause(0.1)

close all;
figure
hold on;
plot(full_list_catb(:,2),full_list_catb(:,1),'ob','LineWidth',2)
plot(full_list_cata(:,2),full_list_cata(:,1),'sr','LineWidth',2)
if length(dpa_latlon(:,1))==1
    plot(dpa_latlon(:,2),dpa_latlon(:,1),'ok')
else
    plot(dpa_latlon(:,2),dpa_latlon(:,1),'-k')
end
grid on;
ylabel('Latitude')
xlabel('Longitude')
title({'Census Tracts'})
plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
filename3=strcat('Step2.png');
saveas(gcf,char(filename3))
pause(0.1)
close all;


end