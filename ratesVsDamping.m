% house keeping
close all
clear all

% femur stiffness values to analyse
kFemur =  (.4:.25:4.5)*1000000; %N/m
% femur damping values to analyse
bFemur = [0 300 600 4000]; %Ns/m

% calculate the loading and displacement rates for the different
% stiffnesses and damping values
[disp,load] = stiffVsRatesData(kFemur,bFemur);

% create the figure
fH1 = figure(1);
set(fH1,'position',[463 29 1066 945],'paperpositionMode','auto');
for i = 1:4
    % calculate a subplot position
    aH = subplot(2,2,i);
    % plot and get plot object handles
    [aHyy(i,:),L1(i),L2(i)] = plotyy(kFemur/1000000,load(i,:)/1000,kFemur/1000000,disp(i,:)*1000); %#ok<*SAGROW>
    % move plotyy axes to the right place based on the subplot location
    oP = get(aH,'position'); % original position
    set(aHyy(i,1),'position',[oP(1)-.025 oP(2:4)],... % location
        'ycolor','k','fontname','times','fontsize',20,... % axes appearance
        'xlim',[0 5],'xtick',[0 1 2 3 4 5],... % x limits and ticks
        'ylim',[0 300],'ytick',[0 150 300]); % y limits and ticks
    
    set(aHyy(i,2),'position',[oP(1)-.025 oP(2:4)],... % location
        'ycolor','k','fontname','times','fontsize',20,... % axes appearance
        'xlim',[0 5],'xtick',[0 1 2 3 4 5],... % x limits and ticks
        'ylim',[0 400],'ytick',[0 200 400]); % y limits and ticks
    
    grid(aHyy(i,1)); % turn the grid on for one axes
    % set the data styles
    set(L1(i),'marker','o','markersize',10,'linestyle','none','markerEdgeColor','k','lineWidth',2)
    set(L2(i),'marker','x','markersize',10,'linestyle','none','markerEdgeColor','k','lineWidth',2)
    % calculate fit lines
    loadingFit(i,:) = polyfit(kFemur,load(i,:),1);
    dispFit(i,:) = polyfit(kFemur,disp(i,:),1);
    % plot the fit lines
    hold(aHyy(i,1))
    plot(aHyy(i,1),kFemur/1000000,polyval(loadingFit(i,:),kFemur)/1000,'--k','linewidth',2)
    hold(aHyy(i,2))
    plot(aHyy(i,2),kFemur/1000000,polyval(dispFit(i,:),kFemur)*1000,'--k','linewidth',2)
    % set the text with the damping values in the upper left corner
    damping = sprintf('%0.1f',bFemur(i)/1000);
    hText = text(.3,260,[damping ' $$\frac{N}{mm/s}$$'],'fontname','times','fontsize',25,'interpreter','latex','HorizontalAlignment','left','backgroundcolor','w');
end
% put axes labels in position
LyP = get(get(aHyy(3,1),'ylabel'),'position');
set(get(aHyy(3,1),'ylabel'),'string','Loading Rate (kN/s)','fontname','times','fontsize',30,'position',[LyP(1) 375 1])
BxP = get(get(aHyy(3,1),'xlabel'),'position');
set(get(aHyy(3,1),'xlabel'),'string','Stiffness (kN/mm)','fontname','times','fontsize',30,'position',[6 BxP(2) 1])
RyP = get(get(aHyy(4,2),'ylabel'),'position');
set(get(aHyy(4,2),'ylabel'),'string','Displacement Rate (mm/s)','fontname','times','fontsize',30,'position',[RyP(1) 500 1])

% put tips in the first plot to indicate which curves are loading and
% displacement.
set(fH1,'currentAxes',aHyy(1,1));
hLoading = text(3.15,225,'Loading','fontname','times','fontsize',20);
set(fH1,'currentAxes',aHyy(1,2));
hDisplace = text(2.5,50,'Displacement','fontname','times','fontsize',20,'HorizontalAlignment','right');

% save the plots as eps (for latex), png (for review) and fig (for easy editing)
print(fH1,'../ratesVsDamping.eps','-r300','-deps');
print(fH1,'ratesVsDamping.png','-r150','-dpng');
saveas(fH1,'ratesVsDamping.fig')
    
    