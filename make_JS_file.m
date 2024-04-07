clear
close all

warning off
matched_data=get_file("AnalyzedSampleDB");
matched_data=readtable(matched_data);
warning on

%Remove PS and field blanks
sample_types=string(matched_data.SampleType);
field_blanks=sample_types=='Field Blank';
point_sources=sample_types=='Point Source';
omit_idx=field_blanks+point_sources;
matched_data(omit_idx>0,:)=[];

%Parse data by unique lat/long
lat_long=matched_data.UseableLatitude;
lat_long(:,2)=matched_data.UseableLongitude;
lat_long=string(lat_long(:,1))+", "+string(lat_long(:,2));
lat_longlist=lat_long;
lat_long=unique(lat_long);

unique_locations=cell([length(lat_long) 1]);
for i=1:length(lat_long)
    unique_locations{i,1}=matched_data(lat_longlist==lat_long(i),:);
end

%Compute maxes and mean of durings
maxes=zeros([length(unique_locations) 1]);
means=maxes;
count=maxes;
lats=maxes;
longs=maxes;
loc_name=string(maxes);
for i=1:length(lat_long)
    tmp=unique_locations{i}.Quant6_PPDQNg_L;
    types=string(unique_locations{i}.SampleType);

    maxes(i,1)=max(tmp);
    tmp2=tmp(types=='During');
    means(i,1)=mean(tmp2);
    count(i,1)=length(tmp2);
    lats(i,1)=unique_locations{i}.UseableLatitude(1);
    longs(i,1)=unique_locations{i}.UseableLongitude(1);
    loc_name(i,1)=unique_locations{i}.SampleKit(1);
end

means(isnan(means))=0;

%Generate size matrix based on logarithm of 6-PPDQ levels
concs_sz_matrix=log(maxes);
concs_sz_matrix(concs_sz_matrix==-Inf)=1;
concs_sz_matrix=concs_sz_matrix*100;




%Generate JS file, each datapoint formatted as:
%const circle2 = L.circle([49.175, -123.9401], {
    %color: 'black',
    %fillColor: '#f02',
    %fillOpacity: 0.5,
    %radius: 500
%}).addTo(map).bindPopup("A different message");


js_colors=string(['#fff5eb';'#fee6ce';'#fdd0a2';'#fdae6b';'#fd8d3c';'#f16913';'#d94801';'#a63603';'#7f2704']);
js_colors(1)="#209e35";
bins=linspace(10,150,9);



for i=1:length(concs_sz_matrix)
    tmp=bins >= maxes(i);
    which_bin=find(tmp);
    which_bin=min(which_bin);
    if isempty(which_bin)
        which_bin=9;
    end
    col_matrix(i,1)=string(js_colors(which_bin));
end
    
%Reorder based on concs (descending) so biggest points are layered on the
%bottom
[concs_sz_matrix,idx]=sort(concs_sz_matrix,1,"descend");
col_matrix=col_matrix(idx);
maxes=maxes(idx);
loc_name=loc_name(idx);
lats=lats(idx);
longs=longs(idx);
means=means(idx);
cd Figures/
pop_up_options="{minWidth: 500, autoClose: true, closeOnClick: true}";
opacity=0.75;
for i=1:length(lat_long)
    next_line="const loc_"+i+" = L.circle(["+lats(i)+", "+longs(i)+"], {";
    next_line=next_line+"color: '"+col_matrix(i)+"', fillcolor: '"+col_matrix(i)+"', fillOpacity: "+opacity+",";

    img_file=get_file(loc_name(i));
    if isempty(img_file)
        next_line=next_line+"radius: "+concs_sz_matrix(i)+'}).addTo(map).bindPopup("'+loc_name(i)+'; max [6-PPDQ]: '+maxes(i)+' ng/L");';
    %Location name version
    else
    %Image version
        next_line=next_line+"radius: "+concs_sz_matrix(i)+'}).addTo(map).bindPopup(''<img src="Figures/'+loc_name(i)+'.png", height="200px"/>'','+pop_up_options+');';
    end
    if i==1
        export=next_line;
    else
        export(end+1,1)=next_line;
    end
end
cd ..

writematrix(export,"max_points.js",'QuoteStrings','none','FileType','text')














function filename=get_file(pat)
cur_dir=dir;

filename=zeros([size(cur_dir,1) 1]);
filename=string(filename);
for i=1:size(cur_dir,1)
    filename(i,1)=string(cur_dir(i).name);
end

del_idx=contains(filename,pat);
filename(del_idx==0,:)=[];
end