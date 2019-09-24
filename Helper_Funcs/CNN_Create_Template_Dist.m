function [heatmap] = CNN_Create_Template_Dist(net,Im,actLayer)

    act = activations(net, Im, actLayer,'OutputAs','channels','ExecutionEnvironment','gpu');

    sz1 = size(act); 

    act1 = reshape(act,[sz1(1) sz1(2) 1 sz1(3)]);

%     for x = 1:sz1(1)
%         for y = 1:sz1(2)
%             heatmap(x,y) = sum(act1(x,y,1,:));
%         end
%     end    
%     
%     heatmap = heatmap ./ max(max(heatmap));  %scale to range 0-1
    
    t=1;
    hact1 = act1;
    for j = 1:sz1(3)
        [mxhact,ytmp] = max(hact1(:,:,1,j));
        [myhact,xtmp] = max(mxhact);
        if myhact == 0
        
        else 
            y(t) = 14 - ytmp(xtmp);
            x(t) = xtmp;
            t=t+1;
        end       
    end
    heatmap = zeros(13);
    for t = 1:length(x)
        heatmap(x(t),y(t)) = heatmap(x(t),y(t))+1;
    end
end




