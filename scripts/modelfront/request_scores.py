#! /usr/bin/python3

import os
import argparse
import logging
import requests

from typing import Dict


def parse_args():
    parser = argparse.ArgumentParser()

    parser.add_argument("--src", type=str, help="Source input lines", required=True)
    parser.add_argument("--trg", type=str, help="Target input lines", required=True)
    parser.add_argument("--scores", type=str, help="File to save output scores.", required=True)

    args = parser.parse_args()

    return args


def send(source_lang: str, target_lang: str, data: Dict, key: str) -> Dict:
    """

    :param source_lang:
    :param target_lang:
    :param data:
    :param key:
    :return:
    """
    url = f'https://api.modelfront.com/v1?sl={source_lang}&tl={target_lang}&token={key}'
    request = requests.post(url, json=data)

    if request.json()['status'] == 'error':
        print(request.json()['status'])
        return {}
    risks = r.json()['risks']
    for i, row in enumerate(data['rows']):
        original = row['original']
        translation = row['translation']
        risk = risks[i]
        print(f'{risk}  \t {sl}: {original}  {tl}: {translation}')


def run(sl, tl, original, translation):
  data = {
    'meta': {},
    'rows': [
      { 'original': original, 'translation': translation}
    ]
  }
  send(sl, tl, data)


def run_batch(sl, tl, tsv_text):
  rows = []
  for line in tsv_text.strip().split('\n'):
    [ original, translation ] = line.split('\t')
    rows += [ { 'original': original, 'translation': translation } ]
  data = {
    'meta':{},
    'rows': rows
  }
  send(sl, tl, data)


def main():

    args = parse_args()

    logging.basicConfig(level=logging.DEBUG)
    logging.debug(args)

    key = os.environ['MODELFRONT_KEY']



if __name__ == '__main__':
    main()
