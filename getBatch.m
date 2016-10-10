function [im, label] = getBatch(imdb, batch)
%GETBATCH  Get a batch of training data
%   [IM, LABEL] = The GETBATCH(IMDB, BATCH) extracts the images IM
%   and labels LABEL from IMDB according to the list of images
%   BATCH.

im_name = imdb.images.name(:,batch);
im_size = size(imread(im_name{1}), 1);
im = single(zeros([size(imread(im_name{1})), size(im_name, 2)]));
label = single(zeros(size(imdb.images.labels, 1),  size(im_name, 2)));
set = imdb.images.set(:,batch);
shift_size = 25;
for i = 1:numel(im_name)
    im(:,:,:,i) = single(imread(im_name{i}));
    im(:,:,:,i) = normalize_image(im(:,:,:,i));
    label(:, i) = single(imdb.images.labels(:, batch(i)))/im_size;
    
    if set(i) ~= 1
        continue
    end
    
    % Data augmentation
    rand_number = randi(2);
    
    if mod(rand_number, 2) == 0
        im(:,:,:,i) = flip(im(:,:,:,i),2);
        for j = 0:13
            if label(j*2 + 1, i) > 0
                label(j*2 + 1, i) = 1.0 - label(j*2 + 1, i);
            end
        end
    end
    
    shift_x = randi([-shift_size, shift_size]);
    shift_y = randi([-shift_size, shift_size]);
    shif_x_normalized = shift_x/im_size;
    shif_y_normalized = shift_y/im_size;
    im(:,:,:,i) = imtranslate(im(:,:,:,i),[shift_x, shift_y]);
    for j = 0:13
        if label(j*2 + 1, i) > 0
            label(j*2 + 1, i) = label(j*2 + 1, i) + shif_x_normalized;
        end
        
        if label(j*2 + 1, i) > 1
            label(j*2 + 1, i) = -1/im_size;
        end
        
        if label(j*2 + 2, i) > 0
            label(j*2 + 2, i) = label(j*2 + 2, i) + shif_y_normalized;
        end
        
        if label(j*2 + 2, i) > 1
            label(j*2 + 2, i) = -1/im_size;
        end
    end
end
label = reshape(label, 1, 1, size(label, 1), size(label, 2));