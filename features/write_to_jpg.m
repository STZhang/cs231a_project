function write_to_jpg(imgs,labels,type)
% INPUT: imgs: HxWx3N matrix containing RGB images stacked together
% OUTPUT: none, written to jpg file

output_dir = 'images';
output_path = fullfile(pwd,output_dir);
mkdir(output_path);
output_txt = fullfile(pwd,[type,'.txt']);
fd = fopen(output_txt,'w');

N = size(imgs,3)/3;
assert(N==size(labels,1));

for i = 1:N
    img = imgs(:,:,((i-1)*3+1):i*3);
    label = labels(i);
    img_path = fullfile(output_path,[type,num2str(i),'.jpg']);
    imwrite(img,img_path);
    
    format_spec = '%s %d\n';
    % caffe label begins at 0
    fprintf(fd,format_spec,img_path,label-1);
    
end

fclose(fd);