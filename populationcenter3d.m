% Find the mean center of world population, using SEDAC population data.
%
%Data Source: SEDAC Gridded Population of the World (2020), 
% https://sedac.ciesin.columbia.edu/data/collection/gpw-v4/sets/browse

Rearth = 6.31e6;
load coastlines

popmap = Tiff('gpw-v4-population-count-rev11_2020_30_min_tif\gpw_v4_population_count_rev11_2020_30_min.tif').read();
popmapnan = popmap;
popmapnan(popmapnan < -1e30) = NaN;
ocean = 1.0*isnan(popmapnan);
ocean(~ocean) = NaN;
popmap(popmap < -1e30) = 0;
countrymap = Tiff('gpw-v4-national-identifier-grid-rev11_30_min_tif\gpw_v4_national_identifier_grid_rev11_30_min.tif').read();
countrymap(countrymap > 2000) = NaN;
lon = -180:.5:180-.5;
lat = 90:-.5:-90+.5;
[longrid,latgrid] = meshgrid(lon,lat);

x = cosd(longrid).*cosd(latgrid);
y = sind(longrid).*cosd(latgrid);
z = sind(latgrid);

meanpop = mean(mean(popmap));
popmeanx = mean(mean(popmap.*x))/meanpop;
popmeany = mean(mean(popmap.*y))/meanpop;
popmeanz = mean(mean(popmap.*z))/meanpop;

clf
colormap bone
c = plot3(cosd(coastlon).*cosd(coastlat),sind(coastlon).*cosd(coastlat),sind(coastlat),'Color',[.4 .4 .4]);
hold on; l = plot3([0 3*popmeanx],[0 3*popmeany],[0 3*popmeanz],'b',popmeanx,popmeany,popmeanz,'.b','LineWidth',3,'MarkerSize',30);
p = patch(surf2patch(x(:,[1:end 1]),y(:,[1:end 1]),z(:,[1:end 1]),-sqrt(popmap(:,[1:end 1]))));shading flat;axis equal;set(p,'FaceAlpha',0.85);set(p,'AmbientStrength',0.4,'SpecularStrength',0.1);view(130,30);camlight;

countries = sort(unique(countrymap(:)));
for i=1:length(countries)
    countrypop(i) = sum(sum(popmap.*(countrymap == countries(i))));
    countrypopmeanx(i) = sum(sum((countrymap ==  countries(i)).*popmap.*x))/countrypop(i);
    countrypopmeany(i) = sum(sum((countrymap ==  countries(i)).*popmap.*y))/countrypop(i);
    countrypopmeanz(i) = sum(sum((countrymap ==  countries(i)).*popmap.*z))/countrypop(i);
    depth(i) = Rearth*(1-sqrt(countrypopmeanx(i).^2 + countrypopmeany(i).^2  + countrypopmeanz(i).^2 ));
end
countries = countries(~isnan(depth));
depth = depth(~isnan(depth));
[depth,ix] = sort(depth,'descend');
countries = countries(ix);
countrypopmeanx = countrypopmeanx(ix);
countrypopmeany = countrypopmeany(ix);
countrypopmeanz = countrypopmeanz(ix);

countrynames = readtable('gpw-v4-country-level-summary-rev11.xlsx','Sheet','GPWv4 Rev11 Summary','Range','A2:D242');

for i=1:length(countries)
countrynames.depth(countrynames.ISONumeric == countries(i)) = depth(i);
end

countriesbydepth = sortrows(countrynames,'depth','descend');
countriesbydepth.CountryOrTerritoryName(1:20);

% Plot maps for individual countries

% for i=1:1
%     hold on
%     xc = x; xc(countrymap ~= countries(i)) = NaN;
%     yc = y; yc(countrymap ~= countries(i)) = NaN;
%     zc = z; zc(countrymap ~= countries(i)) = NaN;
%     pc = patch(surf2patch(xc(:,[1:end 1]),yc(:,[1:end 1]),zc(:,[1:end 1]),-sqrt(popmap(:,[1:end 1]))));shading flat;axis equal;set(pc,'FaceAlpha',0.85);set(pc,'AmbientStrength',0.4,'SpecularStrength',0.1);
%     lc = plot3([0 1.2*countrypopmeanx(i)],[0 1.2*countrypopmeany(i)],[0 1.2*countrypopmeanz(i)],'b',countrypopmeanx(i),countrypopmeany(i),countrypopmeanz(i),'.b','LineWidth',3,'MarkerSize',30);
%     axis equal;
% end
