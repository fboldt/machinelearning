function cascade = feature_selection_cascade_rankingf18w(fscriterion)
cascade = feature_selection_cascade();
cascade = cascade.add_feature_selection_method(cascade, feature_selection_ranking(fscriterion_filter,18));
cascade = cascade.add_feature_selection_method(cascade, feature_selection_ranking(fscriterion));
end

