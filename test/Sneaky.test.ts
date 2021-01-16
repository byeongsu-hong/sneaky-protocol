import chai, { expect } from 'chai';
import { ethers } from 'hardhat';
import { solidity } from 'ethereum-waffle';
import { Contract, ContractFactory, BigNumber, utils } from 'ethers';
import { SignerWithAddress } from '@nomiclabs/hardhat-ethers/dist/src/signer-with-address';
import { advanceTimeAndBlock, latestBlocktime } from './shared/utilities';

chai.use(solidity);

describe('Sneaky', () => {
  const DAY = 86400;
  const ETH = utils.parseEther('1');
  const ZERO = BigNumber.from(0);

  const { provider } = ethers;

  let operator: SignerWithAddress;
  let maker: SignerWithAddress;
  let beneficiary: SignerWithAddress;

  before('provider & accounts setting', async () => {
    [operator, maker, beneficiary] = await ethers.getSigners();
  });

  let MockDAI: ContractFactory;
  let DutchAuction: ContractFactory;
  let SneakyAsset: ContractFactory;
  let SneakersFactory: ContractFactory;

  before('fetch contract factories', async () => {
    MockDAI = await ethers.getContractFactory('MockDAI');
    DutchAuction = await ethers.getContractFactory('DutchAuction');
    SneakyAsset = await ethers.getContractFactory('SneakyAsset');
    SneakersFactory = await ethers.getContractFactory('SneakersFactory');
  });

  let dai: Contract;

  before('deploy test component', async () => {
    dai = await MockDAI.connect(operator).deploy();
  });

  it('works well', async () => {
    const factory = await SneakersFactory.connect(operator).deploy();

    await dai
      .connect(operator)
      .mint(operator.address, utils.parseEther('20000'));
    const auction = await DutchAuction.connect(operator).deploy(
      factory.address,
      maker.address,
      beneficiary.address,
      'George Washington',
      dai.address,
      utils.parseEther('100'),
      (await latestBlocktime(provider)) + 100,
      DAY,
      DAY,
      utils.parseEther('200'),
      utils.parseEther('100')
    );
    await advanceTimeAndBlock(provider, 100);

    await dai
      .connect(operator)
      .approve(auction.address, utils.parseEther('200'));
    await auction.connect(operator).purchase();

    await auction.connect(operator).approve(factory.address, 1);
    await factory
      .connect(operator)
      .makeSneakers(auction.address, 275, 1, operator.address);

    const sneakers = await factory.getSneakers(
      await auction.sneakersName(),
      275
    );
    const newSneakers = await ethers.getContractAt('Sneakers', sneakers);

    console.log(newSneakers.address, (await newSneakers.size()).toString());
  });
});
