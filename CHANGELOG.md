# kubernetes Cookbook CHANGELOG

This file is used to list changes made in each version of the kubernetes cookbook.

## [3.0.0](https://github.com/sous-chefs/kubernetes/compare/v2.0.23...v3.0.0) (2026-11-12)


### ⚠ BREAKING CHANGES

* replace node attributes and the removed v1beta1 API with explicit kubeconfig properties and core/v1 resources. Require Chef 17 or later. Preserve resource names and destroy actions, and add namespace-aware server-side apply with real cluster tests.

### Features

* manage Kubernetes resources through core v1 ([#85](https://github.com/sous-chefs/kubernetes/issues/85)) ([9229aa1](https://github.com/sous-chefs/kubernetes/commit/9229aa1f29e40adf9277b6d2e6803bb2cf529736))


### Bug Fixes

* **ci:** Update workflows to use release pipeline ([#68](https://github.com/sous-chefs/kubernetes/issues/68)) ([59676c1](https://github.com/sous-chefs/kubernetes/commit/59676c13b5666b8bacf8a58a43aee31dd35d9524))
* repair workflow actionlint failures ([#76](https://github.com/sous-chefs/kubernetes/issues/76)) ([fa106bf](https://github.com/sous-chefs/kubernetes/commit/fa106bfbf27f78758a3fedf05a3834943d0c6847))

## [2.0.23](https://github.com/sous-chefs/kubernetes/compare/2.0.22...v2.0.23) (2025-10-15)


### Bug Fixes

* **ci:** Update workflows to use release pipeline ([#68](https://github.com/sous-chefs/kubernetes/issues/68)) ([59676c1](https://github.com/sous-chefs/kubernetes/commit/59676c13b5666b8bacf8a58a43aee31dd35d9524))

## 2.0.13 - *2023-04-07*

Standardise files with files in sous-chefs/repo-management

## 2.0.10 - *2023-04-01*

Standardise files with files in sous-chefs/repo-management

## 2.0.9 - *2023-03-20*

Standardise files with files in sous-chefs/repo-management

## 2.0.8 - *2023-03-15*

Standardise files with files in sous-chefs/repo-management

## 2.0.6 - *2023-02-23*

Standardise files with files in sous-chefs/repo-management

## 2.0.4 - *2023-02-14*

Standardise files with files in sous-chefs/repo-management

## 2.0.3 - *2022-12-15*

Standardise files with files in sous-chefs/repo-management

Standardise files with files in sous-chefs/repo-management

* Update Test Kitchen provisioner settings
* Remove PID one command in Dokken
   * These are all the defaults and we should use the correct container defaults

## 2.0.2 - *2022-02-07*

* Remove delivery and move to calling RSpec directly via a reusable workflow
* Update tested platforms
* Standardise files with files in sous-chefs/repo-management

## 2.0.1 - *2021-11-03*

* Sous-Chefs adoption
* Run test suites in GitHub Actions

## 2.0.0 - *2021-10-26*

* Enabled `unified_mode` for all resources
* Dropped support for Chef < 15.3

## 1.0.2 - *2021-08-30*

* Standardise files with files in sous-chefs/repo-management

## 1.0.1 - *2021-06-01*
