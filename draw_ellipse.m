function draw_ellipse( ax,xc,yc,r1,r2,alpha,ltype)
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
    th = linspace(0,2*pi,50);
    x = cos(th)*r1;
    y = sin(th)*r2;

    plot(ax,xc+x*cos(alpha)-y*sin(alpha),yc+y*cos(alpha)+x*sin(alpha),strcat(ltype,':'));

end

