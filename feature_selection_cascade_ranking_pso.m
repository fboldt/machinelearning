function cascade = feature_selection_cascade_ranking_pso(fscriterion)
cascade = feature_selection_cascade();
cascade = cascade.add_feature_selection_method(cascade, feature_selection_ranking(fscriterion));
cascade = cascade.add_feature_selection_method(cascade, feature_selection_pso(fscriterion));
end

