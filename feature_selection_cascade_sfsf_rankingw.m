function cascade = feature_selection_cascade_sfsf_rankingw(fscriterion)
cascade = feature_selection_cascade();
cascade = cascade.add_feature_selection_method(cascade, feature_selection_sfs(fscriterion_filter));
cascade = cascade.add_feature_selection_method(cascade, feature_selection_ranking(fscriterion));
end

