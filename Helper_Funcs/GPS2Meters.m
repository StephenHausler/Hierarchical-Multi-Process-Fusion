%Function to calculate meters between two GPS coordinates.
function [d, theta] = GPS2Meters(lat1,long1,lat2,long2)
    R = 6378.137;   %radius of earth is km
    dLat = lat2*(pi/180) - lat1*(pi/180);
    dLon = long2*(pi/180) - long1*(pi/180);
    a = sin(dLat/2)*sin(dLat/2) + cos(lat1*(pi/180))*cos(lat2*(pi/180))*sin(dLon/2)*sin(dLon/2);
    c = 2*atan2(sqrt(a),sqrt(1-a));
    d = R*c;
    d = d*1000;
    
    lat1 = deg2rad(lat1); lat2 = deg2rad(lat2); 
    long1 = deg2rad(long1); long2 = deg2rad(long2);
    dLon = long2-long1;
    X = cos(lat2)*sin(dLon);
    Y = cos(lat1)*sin(lat2) - sin(lat1)*cos(lat2)*cos(dLon);
    theta = atan2(X,Y); %output is in radians.
    %theta = rad2deg(theta);
end