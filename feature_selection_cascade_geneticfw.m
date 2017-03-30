function cascade = feature_selection_cascade_geneticfw(fscriterion)
cascade = feature_selection_cascade();
cascade = cascade.add_feature_selection_method(cascade, feature_selection_genetic(fscriterion_filter));
cascade = cascade.add_feature_selection_method(cascade, feature_selection_genetic(fscriterion));
end

