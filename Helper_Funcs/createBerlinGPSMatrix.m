%preload justructs1,2,and 3
matCounter = 1;
GPSMatrix = zeros(315);
for i = 0:118
    g = jstruct3{1,1}.geometry.coordinates{1,674+i};

    gg = cell2mat(g);

    RefLat(matCounter) = gg(2);
    RefLong(matCounter) = gg(1);
    matCounter = matCounter + 1;
end

for i = 1:195
    g = jstruct1{1,1}.geometry.coordinates{1,i};

    gg = cell2mat(g);

    RefLat(matCounter) = gg(2);
    RefLong(matCounter) = gg(1);
    matCounter = matCounter + 1;
end
matCounter = 1;
for i = 1:280
    g = jstruct2{1,1}.geometry.coordinates{1,i};

    gg = cell2mat(g);

    QueryLat(matCounter) = gg(2);
    QueryLong(matCounter) = gg(1);
    matCounter = matCounter + 1;
end
%single dataset:
% %now compute the GPS Matrix:
% for i = 1:length(QueryLat)
%     for j = 1:length(RefLat)
%         d(j) = GPS2Meters(QueryLat(i),QueryLong(i),RefLat(j),RefLong(j));  %lat1,long1,lat2,long2
%         if d(j) <= 50 %meter tolerance
%             GPSMatrix(j,i) = 1;
%         end
%     end
%     clear d;
% end
%train/test split:
%now compute the GPS Matrix:
for i = 1:65 %length(query train images)
    for j = 1:119
        d(j) = GPS2Meters(QueryLat(i),QueryLong(i),RefLat(j),RefLong(j));  %lat1,long1,lat2,long2
        if d(j) <= 50 %meter tolerance
            GPSMatrix_Train(j,i) = 1;
        end
    end
    clear d;
end
%now compute the GPS Matrix:
for i = 66:length(QueryLat) %length(query test images)
    for j = 120:length(RefLat)
        d(j) = GPS2Meters(QueryLat(i),QueryLong(i),RefLat(j),RefLong(j));  %lat1,long1,lat2,long2
        if d(j) <= 50 %meter tolerance
            GPSMatrix_Test(j,i) = 1;
        end
    end
    clear d;
end

save('Berlin_GPS_Matrix_50m_Tr_Te','GPS_Matrix_Train','GPS_Matrix_Test');

% GPSMatrix = sparse(GPSMatrix);
% figure
% imagesc(GPSMatrix)
% save('Berlin_GPSMatrix_50meters','GPSMatrix');

