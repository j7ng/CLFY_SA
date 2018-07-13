CREATE TABLE sa.mtm_cls_group0_cls_factory0 (
  group2cls_factory NUMBER(*,0) NOT NULL,
  factory2cls_group NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_cls_group0_cls_factory0 ADD SUPPLEMENTAL LOG GROUP dmtsora1600533160_0 (factory2cls_group, group2cls_factory) ALWAYS;