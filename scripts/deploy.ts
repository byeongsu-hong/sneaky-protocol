import { ethers } from 'hardhat';
import { utils, BigNumber } from 'ethers';
import { advanceTimeAndBlock, latestBlocktime } from '../test/shared/utilities';

const UNI = {
  UniswapV2Factory: require('@uniswap/v2-core/build/UniswapV2Factory.json'),
  UniswapV2Router: require('@uniswap/v2-periphery/build/UniswapV2Router02.json'),
};

const DAY = 86400;
const ETH = utils.parseEther('1');
const ZERO = BigNumber.from(0);

async function main() {
  const { provider } = ethers;
  const [operator, maker, beneficiary] = await ethers.getSigners();

  const UniswapV2Factory = new ethers.ContractFactory(
    UNI.UniswapV2Factory.abi,
    UNI.UniswapV2Factory.bytecode
  );
  const UniswapV2Router = new ethers.ContractFactory(
    UNI.UniswapV2Router.abi,
    UNI.UniswapV2Router.bytecode
  );

  const uniFactory = await UniswapV2Factory.connect(operator).deploy(
    operator.address
  );
  const uniRouter = await UniswapV2Router.connect(operator).deploy(
    uniFactory.address,
    operator.address
  );

  console.log(`Uniswap Factory: ${uniFactory.address}`);
  console.log(`Uniswap Router: ${uniRouter.address}`);

  const MockDAI = await ethers.getContractFactory('MockDAI');
  const dai = await MockDAI.connect(operator).deploy();
  for await (const acc of [operator, maker, beneficiary]) {
    await dai.connect(operator).mint(acc.address, ETH.mul(10000));
  }

  const SneakersFactory = await ethers.getContractFactory('SneakersFactory');
  const factory = await SneakersFactory.connect(operator).deploy();

  const DutchAuction = await ethers.getContractFactory('DutchAuction');
  const auction = await DutchAuction.connect(operator).deploy(
    factory.address, // 스니커즈 팩토리 주소
    maker.address, // 신발 제조사
    beneficiary.address, // 정산받는 어카운트
    'George Washington', // 스니커즈 이름
    dai.address, // 받고싶은 토큰
    100, // 팔고싶은 쿠폰 갯수
    (await latestBlocktime(provider)) + 100,
    DAY, // 경매 기간 - 하루동안
    7 * DAY, // 트레이딩 기간 - 일주일동안
    utils.parseEther('200'), // 시작 가격
    utils.parseEther('100') // 종료 가격
  );
  await advanceTimeAndBlock(provider, 100);

  console.log(`Factory address: ${factory.address}`);
  console.log(`Sample Auction address: ${auction.address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
