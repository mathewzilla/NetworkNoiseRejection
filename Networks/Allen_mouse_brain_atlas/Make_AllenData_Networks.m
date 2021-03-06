%% script to process Allen data into various matrices for use in the clustering
% 
% allen_CC.mat: Pearson correlation between expression profiles in all n=1299
%               labelled areas (n*n matrix)
% allen_leafnodes.mat: binary array (1=leaf)
%
% Mark Humphries 18/7/2017
clear all; close all;

load allen_CC.mat
load allen_leafnodes.mat
load allen_names.mat

%% check original CC 
k = sum(allen_cc);
zeroIDs = find(k == 0);  % 456 of them. How: because downloaded JSON files are full of NaNs for whole regions

%% load original data
load allen_expression.mat

[nRegions,nGenes] = size(allen_expression);
% find all NaNs
nanIDs = find(isnan(allen_expression));
[nanRegion,nanGene] = ind2sub([nRegions,nGenes],nanIDs);

nanRegionSet = unique(nanRegion);
nanGeneSet = unique(nanGene);

%% single matrix of all leaf-nodes
leafIDs = find(allen_leafnodes == 1);
CC_leaf = allen_cc(leafIDs,leafIDs);

% strip out empty nodes
k = sum(CC_leaf);
keepIDs = find(k > 0);

A = CC_leaf(keepIDs,keepIDs);
leafIDs_final = leafIDs(keepIDs);
nodelabels = allen_names(leafIDs_final,:);

k = sum(A);
[~,iK] = sort(k,'descend');   % plot sorted into degree order
cmap = brewermap(10,'Greys');
figure; 
imagesc(A(iK,iK)); colormap(cmap);

save('../Allen_Gene_Leaf','A','nodelabels','leafIDs_final')

% %% single matrices at individual levels
% 
% load allen_depth.mat
% depths = unique(allen_depths);
% 
% for iD = depths
%     % get all IDs at this depth
%     
%     % make A
%     A = 
%     
%     % strip out empty nodes
%     
%     % final A and node labels
% end


