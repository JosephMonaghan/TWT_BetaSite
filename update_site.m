clear
close all

old_DB=get_file("AnalyzedSampleDB");

cur_folder=cd;

%Database location
cd("/Users/josephmonaghan/Dropbox/BC SRIF TWT Shared Drive/Up-to-date sample results");

new_DB=get_file("AnalyzedSampleDB");

if new_DB ~= old_DB
    status=copyfile(new_DB,cur_folder);
end

cd(cur_folder)

if new_DB ~= old_DB
    if status==1
        delete(old_DB)
    end
end

%Figures location
cd("Figures/")
delete *.jpg

cd("/Users/josephmonaghan/Dropbox/BC SRIF TWT Shared Drive/TC Figures")
status=copyfile("Figures",cur_folder+"/Figures");

if status ~=1
    display("Figure copy failed, try again")
end
cd(cur_folder)

make_JS_file



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