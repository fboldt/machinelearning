function cascade = feature_selection_cascade_sfs_genetic(fscriterion)
cascade = feature_selection_cascade();
cascade = cascade.add_feature_selection_method(cascade, feature_selection_sfs(fscriterion));
cascade = cascade.add_feature_selection_method(cascade, feature_selection_genetic(fscriterion));
end

