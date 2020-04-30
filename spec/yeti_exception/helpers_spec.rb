describe YetiException::Helpers do
  describe '#raise_exception' do
    let(:klass) do
      Class.new do
        include YetiException::Helpers

        def boom
          raise_exception(YetiException::Error,
                          { some: 'details' },
                          false,
                          400)
        end
      end
    end

    subject { klass.new.boom }

    it 'raises the requested exception' do
      expect { subject }.to raise_error do |error|
        expect(error).to be_a(YetiException::Error)
        expect(error.klass).to eq(klass)
        expect(error.details).to eq({ some: 'details' })
        expect(error.transient).to eq(false)
        expect(error.http_status).to eq(400)
      end
    end

    context 'when extra params are omitted' do
      let(:klass) do
        Class.new do
          include YetiException::Helpers

          def boom
            raise_exception(YetiException::Error,
                            { some: 'details' })
          end
        end
      end

      it 'raises the requested exception with defaults' do
        expect { subject }.to raise_error do |error|
          expect(error.transient).to eq(true)
          expect(error.http_status).to eq(500)
        end
      end
    end
  end

  describe '#wrap_exception' do
    let(:klass) do
      Class.new do
        include YetiException::Helpers

        def oops
          # Will be stubbed to raise.  We can't just raise inline because we
          # want to reference the exception's backtrace.
        end

        def boom
          oops
        rescue => ex
          wrap_exception(ex,
                         YetiException::Error,
                         { some: 'details' })
        end
      end
    end
    let(:oops) { StandardError.new('OOPS!') }
    let(:instance) { klass.new }

    before(:each) do
      allow(instance).to receive(:oops).and_raise(oops)
    end

    subject { instance.boom }

    it 'raises a wrapped exception' do
      expect { subject }.to raise_error do |error|
        expect(error).to be_a(YetiException::Error)
        expect(error.klass).to eq(klass)
        expect(error.details).to eq({
                                      msg: 'OOPS!',
                                      some: 'details'
                                    })
        expect(error.backtrace).to eq(oops.backtrace)
      end
    end
  end

  describe '.raise_exception' do
    let(:klass) do
      Class.new do
        include YetiException::Helpers

        def self.boom
          raise_exception(YetiException::Error,
                          { some: 'details' },
                          false,
                          400)
        end
      end
    end

    subject { klass.boom }

    it 'raises the requested exception' do
      expect { subject }.to raise_error do |error|
        expect(error).to be_a(YetiException::Error)
        expect(error.klass).to eq(klass)
        expect(error.details).to eq({ some: 'details' })
        expect(error.transient).to eq(false)
        expect(error.http_status).to eq(400)
      end
    end

    context 'when extra params are omitted' do
      let(:klass) do
        Class.new do
          include YetiException::Helpers

          def self.boom
            raise_exception(YetiException::Error,
                            { some: 'details' })
          end
        end
      end

      it 'raises the requested exception with defaults' do
        expect { subject }.to raise_error do |error|
          expect(error.transient).to eq(true)
          expect(error.http_status).to eq(500)
        end
      end
    end
  end

  describe '.wrap_exception' do
    let(:klass) do
      Class.new do
        include YetiException::Helpers

        def self.oops
          # Will be stubbed to raise.  We can't just raise inline because we
          # want to reference the exception's backtrace.
        end

        def self.boom
          oops
        rescue => ex
          wrap_exception(ex,
                         YetiException::Error,
                         { some: 'details' })
        end
      end
    end
    let(:oops) { StandardError.new('OOPS!') }

    before(:each) do
      allow(klass).to receive(:oops).and_raise(oops)
    end

    subject { klass.boom }

    it 'raises a wrapped exception' do
      expect { subject }.to raise_error do |error|
        expect(error).to be_a(YetiException::Error)
        expect(error.klass).to eq(klass)
        expect(error.details).to eq({
                                      msg: 'OOPS!',
                                      some: 'details'
                                    })
        expect(error.backtrace).to eq(oops.backtrace)
      end
    end
  end
end
