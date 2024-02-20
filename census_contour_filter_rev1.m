function [keep_census_idx]=census_contour_filter_rev1(app,new_full_census_2010,contour_latlon)

%%%%%%%1) Geo Id, 2) Center Lat, 3) Center Lon,  4) NLCD (1-4), 5) Population
mid_lat=new_full_census_2010(:,2);
mid_lon=new_full_census_2010(:,3);


%%%%%might Need to do the rough cut first to speed it up.
min_lat=min(contour_latlon(:,1));
max_lat=max(contour_latlon(:,1));
min_lon=min(contour_latlon(:,2));
max_lon=max(contour_latlon(:,2));

lon_idx1=find(min_lon<mid_lon);
lon_idx2=find(max_lon>mid_lon);
cut_lon_idx=intersect(lon_idx1,lon_idx2);

lat_idx1=find(min_lat<mid_lat);
lat_idx2=find(max_lat>mid_lat);
cut_lat_idx=intersect(lat_idx1,lat_idx2);

check_latlon_idx=intersect(cut_lon_idx,cut_lat_idx);

if ~isempty(check_latlon_idx)
    num_lat_check=length(check_latlon_idx);
    inside_idx=NaN(num_lat_check,1);
    for pos_idx=1:1:num_lat_check
        tf_inside=inpolygon(mid_lon(check_latlon_idx(pos_idx)),mid_lat(check_latlon_idx(pos_idx)),contour_latlon(:,2),contour_latlon(:,1)); %Check to see if the points are in the polygon
        if tf_inside==1
            inside_idx(pos_idx)=pos_idx;
        end
    end
    inside_idx=inside_idx(~isnan(inside_idx));

    if ~isempty(inside_idx)
        keep_census_idx=check_latlon_idx(inside_idx);

% % %         figure;
% % %         hold on;
% % %         plot(contour_latlon(:,2),contour_latlon(:,1),'-r')
% % %         plot(mid_lon(keep_census_idx),mid_lat(keep_census_idx),'xb')
% % %         grid on;
% % %         plot_google_map('maptype','terrain','APIKey','AIzaSyCgnWnM3NMYbWe7N4svoOXE7B2jwIv28F8') %%%Google's API key made by nick.matlab.error@gmail.com
% % %         pause(0.1)
    else
        keep_census_idx=NaN(1,1);
    end
else
    keep_census_idx=NaN(1,1);
end

end