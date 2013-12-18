corpus_path = '/home/dok027/dataset/rcv1/list_from_rcv1_vocab300k_all_by_karl_cca.mat';
%corpus_path = '/home/dok027/dataset/rcv1/list_from_rcv1_vocab300k_all';
%corpus_path = '/home/dok027/dataset/rcv1/list_from_rcv1_vocab300k_small';
%dict_path = '/home/dok027/dataset/rcv1/dict_from_rcv1_vocab300k_all';
dict_path = '/home/dok027/dataset/rcv1/dict_from_rcv1_vocab300k_all_by_karl_cca';
result_path = '/home/dok027/new_brown/cca_embedding/temp';
context_specifier = 'r1';
kappa = 1000;
k = 3;

only_left_cca(corpus_path, context_specifier, kappa, k, result_path);


