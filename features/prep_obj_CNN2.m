%% load config
cfg = 'f06';

disp('Loading configurations ...');    
objty = 'nn08';
cfg = in3d_config(objty, cfg);

%% some hyperparams for cropping
% watch out if the dest_dim_row or col is not odd
dest_dim_row = 227;
dest_dim_col = 227;
img_dim_row = 480;
img_dim_col = 640;
pad_row = 25;
pad_col = 25;

%% load data

disp('Loading data ...');
S = cfg.data.S;
imgs_path = fullfile(cfg.data_dir,'nyu_depth_v2_labeled.mat');
imgs = matfile(imgs_path);

% split
split = cfg.split;
if isfield(split, 'val')
    idx_tr = [split.train; split.val];
    scenes_tr = S(idx_tr);
else
    idx_tr = split.train;
    scenes_tr = S(idx_tr);
end
idx_te = split.test;
scenes_te = S(idx_te);

fprintf('Normal mode: %d scenes (split into %d training and %d testing)\n', ...
    numel(S), numel(scenes_tr), numel(scenes_te));

%% get cropped images
out_train_imgs = zeros(dest_dim_row,dest_dim_col,3*numel(scenes_tr)*8);
out_train_labels = zeros(numel(scenes_tr)*8,1);
out_test_imgs = zeros(dest_dim_row,dest_dim_col,3*numel(scenes_te)*8);
out_test_labels = zeros(numel(scenes_te)*8,1);

types = {'train','test'};

for t = 1:size(types,2)
    % switch over train and test
    type = types(t);
    if strcmp(type,'train')
        scenes = scenes_tr;
        idx_set = idx_tr;
        disp('Collecting training set data ...');
    elseif strcmp(type,'test')
        scenes = scenes_te;
        idx_set = idx_te;
        disp('Collecting test set data ...');
    else
        break;
    end
    
    n = numel(scenes);
    counter = 1;
    
    for i = 1:n
        disp(i);
        s = scenes(i);
        idx = idx_set(i);
        nobjs = numel(s.objects);

        % take out the image
        img = imgs.images(:,:,:,idx);  % imgs.images is 480 640 3 1449

        for j = 1:nobjs
            % take out the bounding box
            % bounding boxes are in the format [xmin, xmax, ymin, ymax]
            bndbox = s.objects(j).bndbox;
            % crop to 227x227x3, containing the bndbox
            center_x = round((bndbox(1)+bndbox(2))/2);
            center_y = round((bndbox(3)+bndbox(4))/2);
            width = bndbox(2) - bndbox(1);
            height = bndbox(4) - bndbox(3);
            
            side = max(width,height)+2*pad_row;
            if side > img_dim_row || side > img_dim_col
                side = min(img_dim_row,img_dim_col);
            end
            
            row_min = center_y - round(side/2);
            row_max = center_y + round(side/2);
            col_min = center_x - round(side/2);
            col_max = center_x + round(side/2);
            % some essential adjustment if reached the edge of image
            if row_min < 1
                row_min = 1;
                row_max = row_min + (side-1);
            end
            if row_max > img_dim_row
                row_max = img_dim_row;
                row_min = row_max - (side-1);
            end
            if col_min < 1
                col_min = 1;
                col_max = col_min + (side-1);
            end
            if col_max > img_dim_col
                col_max = img_dim_col;
                col_min = col_max - (side-1);
            end

            cropped_img = img(row_min:row_max,col_min:col_max,:);
            cropped_img = imresize(cropped_img,[dest_dim_row,dest_dim_col]);

            % take out the label
            label = s.objects(j).label;

            % add to output matrix
            if strcmp(type,'train')
                out_train_imgs(:,:,(3*(counter-1)+1):3*counter) = cropped_img;
                out_train_labels(counter) = label;
                counter = counter + 1;
            else
                out_test_imgs(:,:,(3*(counter-1)+1):3*counter) = cropped_img;
                out_test_labels(counter) = label;
                counter = counter + 1;
            end
        end
    end
end

save train_imgs out_train_imgs -v7.3;
save train_labels out_train_labels -v7.3;
save test_imgs out_test_imgs -v7.3;
save test_labels out_test_labels -v7.3;



