% test of 3D plot
clear;
close all;
T_H = 300 : 10 : 1000;
T_L = 300 : 10 : 1000;
DeltaT = 0 : 10 : 700;
[x1, y1] = meshgrid(T_H, T_L);
[x2, y2] = meshgrid(T_H, DeltaT);
eta1 = eta(x1, y1);
eta2 = eta(x2, x2 - y2);
for i = 1 : numel(eta1(:,1))
    for j = 1 : numel(eta1(1,:))
        if (x1(i,j) < y1(i,j))
            eta1(i,j) = NaN;
        end
        if (x2(i,j) < y2(i,j))
            eta2(i,j) = NaN;
        end
    end
end
subplot(1,2,1);
h1 = mesh(x1, y1, eta1);
% axis([xlim ylim 0 0.4]);
xlabel('T_H');
ylabel('T_L');
zlabel('\eta');

% figure('NextPlot', 'add');
subplot(1,2,2);
h2 = mesh(x2, y2, eta2);
xlabel('T_H');
ylabel('\Delta{}T');
zlabel('\eta');