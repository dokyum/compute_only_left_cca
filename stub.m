corpus_path = '/home/dok027/dataset/rcv1/list_from_rcv1_vocab300k_all_by_karl_cca';
dict_path = '/home/dok027/dataset/rcv1/dict_from_rcv1_vocab300k_all_by_karl_cca';
result_path = '/home/dok027/new_brown/cca_embedding/only_left_cca_rcv1_vocab300k_wocenter_dim1000_kappa1000_lr2';
context_specifier = 'lr2';
kappa = 1000;
k = 1000;

only_left_cca(corpus_path, dict_path, context_specifier, kappa, k, result_path);


