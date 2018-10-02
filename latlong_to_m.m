function northeast=latlong_to_m(lonlat, reflat)
    %R = 0.011131884502145034;
    %north = R*latlon(:,1);
    %east = R*cos(deg2rad(1e-7*latlon(:,1))).*latlon(:,2);
    %northeast=[north,east];
    sc = cos(deg2rad(reflat*1e-7));
    north = lonlat(:,2)* 0.0111318845;
    east = lonlat(:,1).* (0.0111318845*sc);
   
    northeast=[east,north];
end