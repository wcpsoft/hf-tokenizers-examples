use tokenizers::models::bpe::BPE;
use tokenizers::models::bpe::BpeTrainer;
use tokenizers::{AddedToken, DecoderWrapper, NormalizerWrapper, PostProcessorWrapper, PreTokenizerWrapper, Tokenizer, TokenizerImpl};
use anyhow::{Error};
use log::{ info};
use env_logger;

fn main() -> Result<(), Error> {
    // 初始化日志系统
    env_logger::init();

    // 创建新的BPE分词器
    let tokenizer = BPE::builder().unk_token("[UNK]".to_string()).build()
        .map_err(|e| anyhow::anyhow!(e))?;

    let mut tokenizer: TokenizerImpl<
        BPE,
        NormalizerWrapper,
        PreTokenizerWrapper,
        PostProcessorWrapper,
        DecoderWrapper,
    > = TokenizerImpl::new(tokenizer);

    // 定义特殊 token 并创建训练器
    let mut trainer = BpeTrainer::builder()
        .special_tokens(vec![
            AddedToken::from("[UNK]", true),
            AddedToken::from("[CLS]", true),
            AddedToken::from("[SEP]", true),
            AddedToken::from("[PAD]", true),
            AddedToken::from("[MASK]", true),
        ])
        .build();

    // 训练文件路径
    let files = vec![
        "data/wikitext/wiki.test.raw".into(),
    ];

    // 使用文件训练分词器
    tokenizer.train_from_files(&mut trainer, files)
        .map_err(|e| anyhow::anyhow!(e))?;

    // 保存分词器
    tokenizer.save("quickstart/models/tokenizer-wiki.json", false)
        .map_err(|e| anyhow::anyhow!(e))?;
    println!("分词器已保存到 quickstart/models/tokenizer-wiki.json");
    // 从文件加载分词器
    let tokenizer = Tokenizer::from_file("quickstart/models/tokenizer-wiki.json")
        .map_err(|e| anyhow::anyhow!(e))?;

    // 对输入进行编码
    let encoder_result = tokenizer.encode("Hello, y'all! How are you 😁 ?", true)
        .map_err(|e| anyhow::anyhow!(e))?;

    // 输出编码结果
    println!("编码结果: {:?}", encoder_result);
    let decode_result = tokenizer.decode(encoder_result.get_ids(), false);
    println!("解码结果: {:?}", decode_result);
    Ok(())
}
