
Quite self explanatory

## Usage

make scripts executable, provide relevant **ENV VARS** with appropriate values and run script

```bash
chmod +x ./src/*
export SOME_VAR=some_value
./src/some_script.sh
```

### Helium Hotspot

[helium](https://www.helium.com/mine)

`src/helium_hotspot.sh`

### Mina_worker

[minaprotocol](https://minaprotocol.com/)

`src/mina_worker.sh`

|           var           | default       | required |
| :---------------------: | :------------ | :------- |
| `KEY_GENERATOR_VERSION` | 1.0.2-06f3c5c | false    |
|  `MINA_WORKER_VERSION`  | 1.1.4-a8893ab | false    |