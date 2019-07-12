[X,Y] = ndgrid(-100:100, -100:100, 2);
Rx = 30;
Ry = 10;

% Simple Gaussian
w = exp(-(X.^2 + Y.^2)/R^2);

% Different x and y radii.
w = exp(-(X.^2/Rx^2 + Y.^2/Ry^2));

figure,contourf(X,Y,w');
axis equal;