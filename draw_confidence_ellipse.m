function draw_confidence_ellipse( ax,xc,yc,P, ltype )
%draw_ellipse Draw a confidence ellipse
%   Detailed explanation goes here
    [a,b]=eig(P); % get the unit vectors and principle radii
    
    draw_ellipse(ax,xc,yc,sqrt(b(1,1)),sqrt(b(2,2)),atan2(a(1),a(2)),ltype);
    % define the ellipse
%     th = linspace(0,2*pi,50);
%     x = cos(th)*sqrt(b(1,1));
%     y = sin(th)*sqrt(b(2,2));
%     %Transform and plot
%     alpha = atan2(a(1),a(2));
%     plot(ax,xc+x*cos(alpha)-y*sin(alpha),yc+y*cos(alpha)+x*sin(alpha),'r:');
end

