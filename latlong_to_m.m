function east_north=latlong_to_m(lonlat, reference_latitude)

    sc = cos(deg2rad(reference_latitude*1e-7));
    
    north = lonlat(:,2) *  0.0111318845;
    east  = lonlat(:,1).* (0.0111318845*sc);
   
    east_north=[east,north];
end